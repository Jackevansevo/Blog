Title: SQLAlchemy tracking column modifications (Part 2)
Date: 2023-06-23
Status: published
Tags: Python, SQLAlchemy

As a little follow up to yesterdays post about tracking changes to SQLAlchemy models I figured out a way to get this working with [event listeners](https://docs.sqlalchemy.org/en/20/core/event.html#events):

```python
class ChangeTrackingMixin:
    changes: Mapped[Dict] = mapped_column(JSON)

    @staticmethod
    def record_changes(mapper, connection, target):
        dirty_attrs = [
            attr
            for attr in target._sa_instance_state.attrs
            if attr.history.has_changes()
            if attr.key != "changes"
        ]

        if not dirty_attrs:
            return

        if target.changes is None:
            target.changes = {}

        timestamp = dt.datetime.utcnow().isoformat()
        for attr in dirty_attrs:
            if attr.history.has_changes():
                target.changes[attr.key] = timestamp

        flag_modified(target, "changes")

    @classmethod
    def __declare_last__(cls):
        event.listen(cls, "before_insert", cls.record_changes)
        event.listen(cls, "before_update", cls.record_changes)

    def get_updated_at(self, attr):
        updated_at = self.changes.get(attr)
        if updated_at:
            return dt.datetime.fromisoformat(updated_at)
```

## Improvements

The upside of this approach (unlike the [previous approach](/sqlalchemy-tracking-column-modifications.html)) is that timestamps are identical for fields committed at the same time.

```pycon
>>> session = Session(engine)
>>> spongebob = User(name="spongebob", fullname="Spongebob Squarepants")
>>> session.add(spongebob)
>>> session.commit()

# Make some changes
>>> spongebob.name = "Spongebob"
>>> spongebob.fullname = "SpongeBob Martin SquarePants"

>>> session.commit()
>>> session.refresh(spongebob)

# Both 'name' and 'fullname' share the same timestamp
>>> spongebob.get_updated_at('name')
datetime.datetime(2023, 6, 23, 16, 53, 21, 58682)
>>> spongebob.get_updated_at('fullname')
datetime.datetime(2023, 6, 23, 16, 53, 21, 58682)
```

<br>
## Still Missing

The downside of this approach is that it still doesn't work inside SQLAlchemy update statements.

```pycon
>>> spongebob.get_updated_at('name')
datetime.datetime(2023, 6, 23, 17, 3, 57, 128088)

>>> from sqlalchemy import update
>>> session.execute(update(User).values(name="Spongebob"))
<sqlalchemy.engine.cursor.CursorResult object at 0x7fd585e5db70>

>>> session.refresh(spongebob)

# This value hasn't updated :(
>>> spongebob.get_updated_at('name')
datetime.datetime(2023, 6, 23, 17, 3, 57, 128088)
```

This limitation of the `before_update` event listener is alluded to in the [documentation](https://docs.sqlalchemy.org/en/20/orm/events.html#sqlalchemy.orm.MapperEvents.before_update):

![SQLAlchemy documentation https://docs.sqlalchemy.org/en/20/orm/events.html#sqlalchemy.orm.MapperEvents.before_update]({static}/images/Screenshot_20230623_135710.png)


<br>

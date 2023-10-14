Title: SQLAlchemy tracking column modifications
Date: 2023-06-22
Status: published
Tags: Python, SQLAlchemy

Recently I've been playing around with tracking record/field level modifications in SQLAlchemy, here's what I've learnt.

## Tracking record created at / updated at times

A common pattern in SQLAlchemy is to track the `created_at` & `updated_at` values of
individual records.


Typically this is achieved with a
[mixin](https://docs.sqlalchemy.org/en/20/orm/declarative_mixins.html#mixing-in-
columns) as follows:

```python
class TimestampMixin(object):
    created_at: Mapped[dt.datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[dt.datetime] = mapped_column(
        DateTime, default=func.now(), onupdate=func.now()
    )


class User(TimestampMixin, Base):
    __tablename__ = "user_account"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(30))
    fullname: Mapped[Optional[str]]
```

Here's an example of this in practice:

```pycon
>>> session = Session(engine)
>>> spongebob = User(name="spongebob", fullname="Spongebob Squarepants")
>>> session.add(spongebob)
>>> session.commit()

>>> spongebob.created_at
datetime.datetime(2023, 6, 22, 18, 17, 52)

>>> spongebob.updated_at
datetime.datetime(2023, 6, 22, 18, 17, 52)

>>> spongebob.name = "Spongebob"
>>> session.commit()

>>> spongebob.updated_at
datetime.datetime(2023, 6, 22, 18, 18, 11)
```

## Tracking individual field edit times

What if we needed to keep track of when each individual field was
updated/changed independently?

There's a million ways to achieve this, but a simple mechanism I came up with is
to use a mixin that saves individual field changes to a JSON column on each
table

```python
class ChangeTrackingMixin:
    changes: Mapped[Dict] = mapped_column(JSON, default=JSON.NULL)

    def __setattr__(self, attr, value):
        if attr != "changes" and attr in self.__table__.c.keys():
            self._record_field_change(attr, value)
        super().__setattr__(attr, value)

    def _record_field_change(self, attr, new_value):
        if self.changes is JSON.NULL or self.changes is None:
            self.changes = {}
        self.changes[attr] = {
            "value": new_value,
            "updated_at": dt.datetime.now().isoformat(),
        }
        flag_modified(self, "changes")

    def get_updated_at(self, attr):
        updated_at = self.changes.get(attr, {}).get("updated_at")
        if updated_at:
            return dt.datetime.fromisoformat(updated_at)
```

## How it works

The 'magic' here is this section:

```python
def __setattr__(self, attr, value):
    if attr != "changes" and attr in self.__table__.c.keys():
        self._record_field_change(attr, value)
    super().__setattr__(attr, value)
```

This `__setattr__` method gets called every time we try to modify the attribute
of a user record.

If we happen to be editing one of the keys in the user table (ignoring the `"changes"` field):

```python
if attr != "changes" and attr in self.__table__.c.keys():
```

Then we call some extra bookkeeping logic:


```python
self._record_field_change(attr, value)

```

Then fall back to calling the original logic to update the field

```python
super().__setattr__(attr, value)
```

<br>


## Usage

To lookup the individual edit time of a field you can write

```pycon
>>> obj.get_updated_at('field_name')
```

You can see this in action below:

```pycon
>>> session = Session(engine)
>>> spongebob = User(name="spongebob", fullname="Spongebob Squarepants")
>>> session.add(spongebob)
>>> session.commit()

>>> spongebob.created_at
datetime.datetime(2023, 6, 22, 19, 6, 11)

>>> spongebob.updated_at
datetime.datetime(2023, 6, 22, 19, 6, 11)

# Update the name (uppercase 'S')
>>> spongebob.name = "Spongebob"
>>> session.commit()

# Reflects the new timestamp of when 'name' was updated
>>> spongebob.get_updated_at("name")
datetime.datetime(2023, 6, 22, 16, 6, 53, 350103)

# Note 'fullname' still retains its earlier value
>>> spongebob.changes
{'name': {'value': 'Spongebob', 'updated_at': '2023-06-22T16:06:53.350103'}, 'fullname': {'value': 'Spongebob Squarepants', 'updated_at': '2023-06-22T16:06:04.176241'}}
```

<br>

## Downsides

### No server time

A major issue with this approach is we're no longer using the server time
`func.now()`. Instead we're using the local time of the Python environment
executing the code.

```python
dt.datetime.now().isoformat()
```

Unfortunately this means that the `updated_at` timestamp will be different for
each dirty field in the session when committed. This is demonstrated below:


```pycon
>>> session = Session(engine)
>>> spongebob = User(name="spongebob", fullname="Spongebob Squarepants")
>>> session.add(spongebob)
>>> session.commit()

# Both these values are the same (computed server side)
>>> spongebob.created_at
datetime.datetime(2023, 6, 22, 19, 6, 11)

>>> spongebob.updated_at
datetime.datetime(2023, 6, 22, 19, 6, 11)

# Each of these individual field values are different :(
>>> spongebob.get_updated_at("fullname")
datetime.datetime(2023, 6, 22, 16, 6, 4, 176241)

>>> spongebob.get_updated_at("name")
datetime.datetime(2023, 6, 22, 16, 6, 4, 176218)
```

### Doesn't work with update statements

Mutating the record with an update will not propagate changes to the JSON column
timestamps:

```pycon
>>> session = Session(engine)
>>> spongebob = User(name="spongebob", fullname="Spongebob Squarepants")
>>> session.add(spongebob)
>>> session.commit()

>>> spongebob.get_updated_at('name')
datetime.datetime(2023, 6, 22, 16, 38, 25, 595457)

>>> session.execute(update(User).values(name="Spongebob"))
<sqlalchemy.engine.cursor.CursorResult object at 0x7f2cd49657f0>

>>> session.refresh(spongebob)

# This value is is the same as before!!!
>>> spongebob.get_updated_at('name')
datetime.datetime(2023, 6, 22, 16, 38, 25, 595457)
```

To compare, using an `update` statement does update record level `updated_at`
field from the `TimestampMixin`

```pycon
>>> session = Session(engine)
>>> spongebob = User(name="spongebob", fullname="Spongebob Squarepants")
>>> session.add(spongebob)
>>> session.commit()

>>> spongebob.updated_at
datetime.datetime(2023, 6, 22, 19, 35, 52)

>>> session.execute(update(User).values(name="Spongebob"))
<sqlalchemy.engine.cursor.CursorResult object at 0x7f35d8f697f0>

>>> session.refresh(spongebob)

# Value is updated!
>>> spongebob.updated_at
datetime.datetime(2023, 6, 22, 19, 36, 10)
```

# Conclusion

Perhaps there's a clever mechanism with event listeners that avoids these
drawbacks but I've yet to figure it out.

If you happen to know and I haven't updated this post, please let me know what
I'm missing!

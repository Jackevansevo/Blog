Title: An Sqlalchemy Footgun Revisited
Date: 2022-07-19
Status: published
Tags: Python, SQLAlchemy

In this [previous post](/posts/an-sqlalchemy-footgun/) I wrote about shooting myself in the foot 🔫 with Cartesian products in SQLAlchemy.

Lets visit the SQLAlchemy model example:

```python
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    items = relationship("Item", back_populates="owner")


class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="items")

```

## Database Setup

Recall: in the DB we had x2 `User`(s) (Homer & Marge), and x2 `Item`(s) associated with Homer

```python
>>> db.query(User.id, User.email).all()
>>> [(1, 'homer.simpson@gmail.com'), (2, 'marge.simpson@gmail.com')]

>>> db.query(Item.title, Item.owner_id).all()
>>> [('Duff Beer', 1), ('Lard Lad Donut', 1)]

# Items associated with homer
>>> db.query(User).get(1).items
>>>
[<reddit.models.Item at 0x7f338ea97730>,
 <reddit.models.Item at 0x7f338ea96e00>]

# Items associated with marge
>>> db.query(User).get(2).items
>>> []
```

## Old Behaviour

In the previous post we wanted to write a query to fetch all the `Item`(s) associated with `marge.simpson@gmail.com`

```python
>>> db.query(Item.title).filter(User.email==marge.email).all()
[('Duff Beer',), ('Lard Lad Donut',)]
```

In the background SQLAlchemy would silently perform a cartesian join, sometimes
having unintentional results (in this case returning ALL `Item`(s)).

## New Behaviour

If we're using SQLalchemy 2.0 and we attempt to execute this query without first joining on the `User` table we now get a warning:

```python
>>> db.query(Item.title).filter(User.email == marge.email).all()
<ipython-input-11-d6991ed67293>:1: SAWarning: SELECT statement has a cartesian product between FROM element(s) "users" and FROM element "items".  Apply join condition(s) between each element to resolve.
  db.query(Item.title, Item.owner_id).filter(User.email == marge.email).all()
[('Duff Beer',), ('Lard Lad Donut', )]
```


```
SAWarning: SELECT statement has a cartesian product between FROM element(s) "users" and FROM element "items".  Apply join condition(s) between each element to resolve.
```


Which I think this is really awesome 🥳

---

Aside: Here's the equivalent query rewritten in the newer SQLALchemy 2.0 query style:

```python
>>> marge = db.get(User, 2)

>>> stmt = select(Item.title).where(User.email == marge.email)

>>> db.execute(stmt).all()
<ipython-input-5-971dc4667e1f>:1: SAWarning: SELECT statement has a cartesian product between FROM element(s) "users" and FROM element "items".  Apply join condition(s) between each element to resolve.
  db.execute(stmt).all()
[('Duff Beer',), ('Lard Lad Donut',)]
```

As discussed in the previous post, what we really want is:

```python
>>> stmt = select(Item.title).join(User).where(User.email == marge.email)

>>> db.execute(stmt).all()
[]
```

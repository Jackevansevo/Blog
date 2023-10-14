Title: An SQLAlchemy Footgun
Date: 2022-06-04
Status: published
Tags: Python, SQLAlchemy

Something I learnt the hard way recently.

Let's say you have the following SQLAlchemy models, representing a straightforward many-to-one relationship:


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

Each `Item` has a parent `User`, each `User` can have multiple `items`.

In my DB I've got the following data (x2 Users (Homer & Marge), and x2 Items associated with Homer)

```python
>>> db.query(User.id, User.email).all()
[(1, 'homer.simpson@gmail.com'), (2, 'marge.simpson@gmail.com')]

>>> db.query(Item.title, Item.owner_id).all()
[('Duff Beer', 1), ('Lard Lad Donut', 1)]

# Items associated with homer
>>> db.query(User).get(1).items
[<reddit.models.Item at 0x7f338ea97730>,
 <reddit.models.Item at 0x7f338ea96e00>]

# Items associated with marge
>>> db.query(User).get(2).items
[]
```


![Homer Simpson eating a donut](https://upload.wikimedia.org/wikipedia/en/0/02/Homer_Simpson_2006.png)

<br>

Lets say I want to write a query to fetch me all the `Items` associated with `marge.simpson@gmail.com`

```python
>>> db.query(Item.title).filter(User.email==marge.email).all()
[('Duff Beer',), ('Lard Lad Donut',)]
```
<br>

> 🤔 Hold on, this looks to have returned all the items associated with Homer, what's going on here?

<br>
Lets peek under the hood by printing the generated SQL.

```python
>>> print(db.query(Item.title).filter(User.email==marge.email))
```

```sql
SELECT items.title AS items_title
FROM items, users
WHERE users.email = ?
```

Looks like the above is missing a `.join` clause, and its absence can be disastrous. Turns out SQLAlchemy will happily let you `filter` by a clause for a column you've not joined on.

What you need to do is explicitly `.join()` on the `user` table:

```python

>>> db.query(Item.title).join(User).filter(User.email==marge.email).all()
[]
```

We can prove this is doing the right thing:

```python
>>> print(db.query(Item.title).join(User).filter(User.email==marge.email))
```

```sql
SELECT items.title AS items_title
FROM items JOIN users ON users.id = items.owner_id
WHERE users.email = ?
```


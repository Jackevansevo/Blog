Title: TIL: SQLAlchemy 2.0 changes in cascading session behaviour
Date: 2023-04-02
Status: published
Tags: Python, SQLAlchemy

Recently at work I've been upgrading our SQLAlchemy dependency from 1.4 -> 2.0. Along the way I encountered a curious (but documented) change in behaviour.

After skimming the [migration guide](https://docs.sqlalchemy.org/en/20/changelog/migration_20.html) and [release notes](https://docs.sqlalchemy.org/en/20/changelog/changelog_20.html) I decided to blindly bump the dependency, run the integration test suite and see what exploded 💥.

```
....X......X
```

I observed a few test failing and noticed certain DB objects were missing ID's. After setting up some breakpoints and stepping through the tests it appeared that the objects in question were no longer being added to the session.

The code looked something like this:

```python
user = session.get(User, user_id) # user is in session
person = Person()
person.user = user

breakpoint()
assert person.user in session #  False

session.flush() # previously expected this to populate person.id
```


If the person object was no longer being added to the session correctly this
explains why no ID's were generated when the session was flushed.

I managed to reduce this issue down to the following reproducible example.
Running this script with SQLAlchemy 1.4 vs SQLAlchemy 2.0 yields different
results.

```python
from sqlalchemy import Column, ForeignKey, Integer, String, create_engine
from sqlalchemy.orm import Session, declarative_base, relationship

Base = declarative_base()


class Person(Base):
    __tablename__ = "person"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("user.id"), index=True)
    user = relationship("User", back_populates="persons")


class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    persons = relationship("Person", back_populates="user", cascade="all, delete")


engine = create_engine("sqlite://", echo=False)
Base.metadata.drop_all(engine)
Base.metadata.create_all(engine)

# Add user to DB
with Session(engine) as session:
    user = User(name="Jack")
    session.add(user)
    session.commit()

# Simulate what prod endpoint is doing
with Session(engine) as session:
    user = session.get(User, 1)
    print("user in session:", user in session)

    # By associated the person is now part of the session
    person = Person(user=user)
    print("person in session:", person in session)

    session.flush()

    # Will the person.id be populated???
    print("person.id", str(person.id))
```


As it turns out, our codebase was reliant on the behaviour of unintended side
effects with backrefs in SQLAlchemy 1.4, where related objects would previously get cascaded into the session.

This behaviour (which caught me out) is well documented in the release notes [here](https://docs.sqlalchemy.org/en/20/changelog/migration_14.html#cascade-backrefs-behavior-deprecated-for-removal-in-2-0), which I'd have spotted if I read closer 🤦. Here's the relevant section:

<img alt="screenshot of release notes section documenting this change" src="{static}/images/Screenshot_20230402_101443.png"></img>


## Lessons Learnt

Next time to read the release notes, especially if they comprehensive!

<br>

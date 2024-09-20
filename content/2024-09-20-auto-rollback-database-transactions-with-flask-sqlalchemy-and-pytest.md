Title: Auto rollback database transactions with Flask-SQLAlchemy and pytest
Date: 2024-09-20
Status: published
Tags: python, flask, sqlalchemy, pytest

TLDR: I wanted (the not uncommon use-case) to having each test run in its own isolated transaction.

This makes testing application logic easier as arbitrary database changes can be made within each test with confidence that data will be  rolled back once the test exits.

At first I tried out the [pytest-flask-sqlalchemy plugin](https://github.com/jeancochrane/pytest-flask-sqlalchemy/issues), but this appears to be incompatible with Flask-SQLAlchemhy 3.0

After quite a bit of searching I came across this [Github Issue](https://github.com/pallets-eco/flask-sqlalchemy/issues/1171) on the `Flask-SQLAlchemy` issue tracker which seems to be the only solution that currently works.

Below is an example of how that snippet fits into an example toy Flaksk app:

```python
from flask import Blueprint, Flask
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import select
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


db = SQLAlchemy(model_class=Base)


class User(Base):
    __tablename__ = "user"
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(unique=True)


index = Blueprint("index", __name__, url_prefix="/")


@index.route("/")
def users():
    return [
        {"id": user.id, "email": user.email}
        for user in db.session.scalars(select(User))
    ]


def create_app(db_uri="sqlite:///project.db"):
    app = Flask(__name__)
    app.config["SQLALCHEMY_DATABASE_URI"] = db_uri
    db.init_app(app)
    app.register_blueprint(index)
    return app
```

Here's an example `conftest.py`

```python
import pytest

from app import User, create_app, db


@pytest.fixture(scope="session")
def app():
    app = create_app("sqlite:///:memory:")
    yield app


@pytest.fixture(autouse=True)
def app_ctx(app):
    with app.app_context():
        yield app


@pytest.fixture(scope="session")
def client(app):
    return app.test_client()


@pytest.fixture(scope="session", autouse=True)
def tables(app):
    with app.app_context():
        db.create_all()


@pytest.fixture(autouse=True, scope="function")
def transaction(app):
    # https://github.com/pallets-eco/flask-sqlalchemy/issues/1171
    with app.app_context():
        engines = db.engines

    engine_cleanup = []

    for key, engine in engines.items():
        connection = engine.connect()
        transaction = connection.begin()
        engines[key] = connection
        engine_cleanup.append((key, engine, connection, transaction))

    yield

    for key, engine, connection, transaction in engine_cleanup:
        transaction.rollback()
        connection.close()
        engines[key] = engine
```

This enables me to then write tests that depend on the `db.session` global which are completely self contained:

```python
def test_a(client):
    user = User(email="test@google.com")
    db.session.add(user)
    db.session.commit()
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.json == [{"email": "test@google.com", "id": 1}]


def test_b(client):
    user = User(email="test@google.com")
    db.session.add(user)
    db.session.commit()
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.json == [{"email": "test@google.com", "id": 1}]
```

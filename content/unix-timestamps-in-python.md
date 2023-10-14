Title: TIL: How Unix timestamps work in Python
Date: 2023-02-26
Status: published
Tags: Python

# The Problem:

A while back I wrote some tests that generated and compared timestamps. At the
time I wrote the tests I was in the UK (GMT/UTC+0).

This week I changed the timezone of my machine and re-ran the same tests and
(much to my dismay) they failed ...

The tests depended on generating timestamps with:

```python
>>> from datetime import datetime, timezone
>>> now = datetime.now()
>>> now
datetime.datetime(2023, 2, 26, 14, 48, 26, 461197)
>>> now.timestamp()
1677433706.461197
```

Somewhere in the code these timestamps are converted from a timestamp to
a datetime.


```
>>> from marshmallow import Schema, fields
>>> class MySchema(Schema):
...     timestamp = fields.DateTime(format='timestamp')
...

>>> now
datetime.datetime(2023, 2, 26, 14, 48, 26, 461197)

>>> MySchema().load({'timestamp': now.timestamp()})
{'timestamp': datetime.datetime(2023, 2, 26, 17, 48, 26, 461197)}
```

Strangely, the act of converting the timestamp had caused it to leap ahead by
3 hours.

# Debugging

[Under the
hood](https://github.com/marshmallow-code/marshmallow/blob/eae0652de3c393e85976f05b6744eda815802c48/src/marshmallow/utils.py#L193-L200),
Marshmallow is (correctly) loading the timestamp as UTC.

```python
def from_timestamp(value: typing.Any) -> dt.datetime:
    value = float(value)
    if value < 0:
        raise ValueError("Not a valid POSIX timestamp")

    # Load a timestamp with utc as timezone to prevent using system timezone.
    # Then set timezone to None, to let the Field handle adding timezone info.
    return dt.datetime.fromtimestamp(value, tz=dt.timezone.utc).replace(tzinfo=None)
```

This all seems pretty sensible so made me realize the bug was probably due to
the mechanism I was using to create timestamps in the first place.

It's more clear once you take the timestamp and run it through
[epochconverter.com](https://www.epochconverter.com):


![Calculator converting epoch to human readable date]({static}/images/Screenshot from 2023-02-26 14-50-20.png)

This timestamp turns out to be system time on my machine (which is 17:48 GMT).

```python
>>> now
datetime.datetime(2023, 2, 26, 14, 48, 26, 461197)
>>> now.timestamp()
1677433706.461197
```

The following causes the time to leap ahead because it's assuming the original
timestamp is already in UTC.

```python
>>> dt.datetime.fromtimestamp(now.timestamp(), tz=dt.timezone.utc).replace(tzinfo=None)
datetime.datetime(2023, 2, 26, 17, 48, 26, 461197)
```


# The Fix:

Instead I needed to write:

```python
>>> now.replace(tzinfo=timezone.utc).timestamp()
1677422906.461197
```

![Calculator converting epoch to human readable date]({static}/images/Screenshot from 2023-02-26 15-13-11.png)


There's a note about this behaviour in the
[documentation](https://docs.python.org/3/library/datetime.html#datetime.datetime.timestamp)
for `datetime.datetime.timestamp`

![Screenshot of documentation]({static}/images/Screenshot from 2023-02-26 15-21-24.png)

With this fix in place, the conversion now works as expected:

```python
>>> now
datetime.datetime(2023, 2, 26, 14, 48, 26, 461197)

>>> schema.load({'timestamp': now.timestamp()})
{'timestamp': datetime.datetime(2023, 2, 26, 17, 48, 26, 461197)}

>>> schema.load({'timestamp': now.replace(tzinfo=timezone.utc).timestamp()})
{'timestamp': datetime.datetime(2023, 2, 26, 14, 48, 26, 461197)}
```

# Lessons Learnt

I guess the key takeaway from this is not to ever write tests that depend on
a specific system time, and always try to adhere to UTC, (unless you're
specifically forced not to).

<br>


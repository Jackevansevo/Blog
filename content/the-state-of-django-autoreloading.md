Title: The State of Django Autoreloading
Date: 2022-09-19
Status: published
Tags: Python, Django

Encountering a bug in <code>pywatchman</code> and exploring an alterate file reloading solution.

**TLDR:** On Python-3.10 watchman bindings are broken. My recommendation is to
use: [django-watchfiles](https://pypi.org/project/django-watchfiles/)

## What the Docs Say

I recently went down a bit of a rabbit hole debugging auto reloading in Django.

The [official documentation](https://docs.djangoproject.com/en/4.1/ref/django-admin/#runserver) for Django `runserver` states

> The development server automatically reloads Python code for each request, as
> needed. You don’t need to restart the server for code changes to take effect...

And that:

> If you’re using Linux or MacOS and install both pywatchman and the Watchman
> service, kernel signals will be used to autoreload the server (rather than
> polling file modification timestamps each second). This offers better
> performance on large projects...



So by default `./manage.py runserver` Should work out of the box, but it's not
particularly efficient for bigger projects.

Optionally: installing the `watchman` binary (a file watching service by Facebook) and the
`pywatchman` (the python bindings) should result in a smoother experience.

---

## My Experience

In the past I've found the default reloader doesn't always restart the server
when I'd expect it to.

Recently I started a new project (with `Python 3.10.6`) so I figured I'd give
the watchman reloader a try.

I installed the `watchman` binary via my distribution package manager and
`pywatchman` via pip

To my confusion: the `StatReloader` (the default/fallback) was still being used 🤔

```shell
❯ ./manage.py runserver
Watching for file changes with StatReloader
Performing system checks...
```


## Investigation

Let's have a look at why this is happening 🕵️

Django's reloading implementation can be found in [django/utils/autoreload.py](https://github.com/django/django/blob/main/django/utils/autoreload.py#L640-L646)

```python
def get_reloader():
    """Return the most suitable reloader for this environment."""
    try:
        WatchmanReloader.check_availability()
    except WatchmanUnavailable:
        return StatReloader()
    return WatchmanReloader()
```

It looks like by default Django will first check to see if watchman is
available, and call back to the default stat reloader if the compatibility
check fails.


**The Smoking Gun**

If the check fails: `get_reloader` will swallow the exception and silently
fall back to using the stat `StatReloader`. From the end user perspective
(someone executing `./manage.py runserver`) there's no indication why the
availability check failed.

### Reproducing

So lets dig a little further:

The `check_availability` method on `WatchmanReloader` implementation can be found [here](https://github.com/django/django/blob/cfe3008123ed7c9e3f3a4d51d4a22f9d96634e33/django/utils/autoreload.py#L622-L637)

The important lines are:

```python
if not pywatchman:
    raise WatchmanUnavailable("pywatchman not installed.")
client = pywatchman.client(timeout=0.1)
try:
    result = client.capabilityCheck()
except Exception:
    # The service is down?
    raise WatchmanUnavailable("Cannot connect to the watchman service.")
```

Where the `pywatchman` variable being checked against is just a module level
import wrapped with a `try/except` block (to check if the `pywatchman` python
package is available)

```python
try:
    import pywatchman
except ImportError:
    pywatchman = None
```




If I open a shell and execute this code:

```python
>>> import pywatchman
>>> client = pywatchman.client(timeout=0.1)
>>> result = client.capabilityCheck()
```

I get the following exception 💥 (the same exception unfortunately gets swallowed by Django).

```python
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/jackevans/.local/share/virtualenvs/blog-ZV8xlUiZ/lib/python3.10/site-packages/pywatchman/__init__.py", line 1071, in capabilityCheck
    res = self.query('version', {
  File "/home/jackevans/.local/share/virtualenvs/blog-ZV8xlUiZ/lib/python3.10/site-packages/pywatchman/__init__.py", line 1048, in query
    self._connect()
  File "/home/jackevans/.local/share/virtualenvs/blog-ZV8xlUiZ/lib/python3.10/site-packages/pywatchman/__init__.py", line 917, in _connect
    self.sockpath = self._resolvesockname()
  File "/home/jackevans/.local/share/virtualenvs/blog-ZV8xlUiZ/lib/python3.10/site-packages/pywatchman/__init__.py", line 904, in _resolvesockname
    result = bser.loads(stdout)
SystemError: PY_SSIZE_T_CLEAN macro must be defined for '#' formats
```

It looks like the `capabilityCheck()` call is failing due to an exception raised
inside `pywatchman`.

Mystery solved 🔮 this explains why `StatReloader` (not `WatchmanReloader`) is
being used, despite all the necessary pre-requisite dependencies being available.


## An Alternative Solution

After a bit of Googling I ended up in [this github issue
thread](https://github.com/facebook/watchman/issues/970), which was originally
opened on 2 Nov 2021.

It appears like there was a change in Python 3.10 that caused things to break
in pywatchman library. Consequently bindings will need updating to work for
newer Python releases.

According to the thread: a [pre-release
fix](https://github.com/facebook/watchman/issues/970#issuecomment-1002054941)
is available, it just hasn't been tagged/released on PyPI. There's a lot of
frustration in the thread with commenters requesting that the patch/fix be officially
merged/released.

Luckily, in the mean time one of the
[suggestions](https://github.com/facebook/watchman/issues/970#issuecomment-1191330203)
in the thread pointed me towards
[django-watchfiles](https://pypi.org/project/django-watchfiles/).

`django-watchfiles` provides Django integration with `watchfiles`, which itself is a set of Python bindings for the underlying `notify` file-system notification library written in rust.

Similar to the way `pywathman` provides bindings to the `Watchman`
file-watching service, both solutions implement performance sensitive
operations (low file watching events) in a lower level language, providing
higher level language wrappers for the Python ecosystem.

I've found that `django-watchfiles` works very nicely out of the box, so gets
my approval 👍

## Conclusion

Hopefully either the `pywatchman` library will be updated in the future or the
Django documentation will include a disclaimer about broken behaviour in
Python-3.10+.

Otherwise future developers are destined to retrace my footsteps (maybe you even found this blog post)

In the meantime, I'll continue to use `django-watchfiles`.

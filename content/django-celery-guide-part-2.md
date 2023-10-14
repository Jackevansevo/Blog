Title: Django Celery Guide (Part 2)
Date: 2022-09-24
Status: published
Tags: Python, Django

Using Django ORM as a Results Backend


![django-celery-redis logo]({static}/images/django-celery-redis-logo.png)

In [part 1](/posts/django-celery-guide-part-1) we got a celery worker up and
running, using a redis instance as our celery broker and results backend.

In this section we're going to explore using `django-celery-results` as a
replacement results backend (instead of results being stored in Redis).

With `django-celery-results` installed our app is going to instead look like:

![django celery results diagram]({static}/images/django-celery-results-diagram.png)

<code>Redis</code> is still our celery **task broker**, therefore remains responsible for
distributing tasks amongst celery workers and brokering communication with our
celery app.

However, instead of using redis as our **results backend** to save task
results, we'll be storing results in <code>SQLite</code>, our chosen Django DB
implementation (the default).


## Installation

```shell
pipenv install django-celery-results
```

From here, it's a good idea to follow the [installation
instructions](https://docs.celeryq.dev/en/latest/django/first-steps-with-django.html#django-celery-results-using-the-django-orm-cache-as-a-result-backend)
in the official documentation.

For us this is essentially the following steps:

**Add `django_celery_results` to `INSTALLED_APPS`**

```diff
 INSTALLED_APPS = [
     "django.contrib.admin",
     "django.contrib.auth",
     "django.contrib.contenttypes",
     "django.contrib.sessions",
     "django.contrib.messages",
     "django.contrib.staticfiles",
+     "django_celery_results",
     "posts.apps.PostsConfig",
 ]
```

**Run a migration to create necessary database tables**

```shell
pipenv run ./manage.py migrate django_celery_results
```

**Update the `CELERY_RESULT_BACKEND` variable in `blog/settings.py`**

```diff
-CELERY_RESULT_BACKEND = "redis://localhost/0"
+CELERY_RESULT_BACKEND = "django-db"
```

After installing, if you head to the admin console you should now be greeted with a new table "CELERY RESULTS"

![django admin celery-results]({static}/images/django-admin-celery-results.png)

## Testing

Once again if we start our celery worker with:

```shell
pipenv run celery -A blog worker
```

And trigger a task from the celery shell with:

```shell
pipenv run celery -A blog shell
```

And the following Python code:

```python
>>> square.delay(5)
<AsyncResult: 0aeb5a1d-157d-4fcd-8508-a8bf70ba2b70>
```

Once the task has executed, From the Django admin page, navigate through to the
'Task results' table entry under 'CELERY RESULTS', you should now see celery
result has been saved in the Django DB:

![django admin celery-result]({static}/images/django-admin-celery-result.png)

## Including Task Metadata

In the screenshot you'll notice our task row/item is missing data in the **TASK
NAME** and **WORKER** columns.

To make sure this metadata is included you need to set the
`CELERY_RESULT_EXTENDED` value to `True` in your application settings. Credit
goes to [this comment](https://github.com/celery/django-celery-results/issues/326#issuecomment-11815806)

```python
CELERY_RESULT_EXTENDED = True
```

After applying this change and reloading celery this data should now be
included for any new tasks:


![django admin celery-result-v2]({static}/images/django-admin-celery-result-v2.png)

If a celery task triggers an exception:

```python
>>> res = square.delay("10")
>>> # res.get() will raise: TypeError: can't multiply sequence by non-int of type 'str'
```

All this data is nicely neatly captured/surfaced inside the Django admin.

![django-admin-celery-result-failure.png]({static}/images/django-admin-celery-result-failure.png)

## Querying Data

Having task data stored in the Django DB makes it straightforward to query data
and browse/explore/filter tasks using the ORM.

Additionally, we also get the power of Django's powerful admin interface to
explore celery tasks & results. All this is possible by the underlying ORM
integration. No additional redis admin dashboard is required to explore this
data, it all lives in the same place.

```python
>>> from django_celery_results.models import TaskResult
>>> TaskResult.objects.all()
<QuerySet [<TaskResult: <Task: a24c7342-0532-4374-a67d-264c0e12c082 (FAILURE)>>, <TaskResult: <Task: 30864968-887c-4399-8d88-b79ae7492f61 (SUCCESS)>>, <TaskResult: <Task: 0aeb5a1d-157d-4fcd-8508-a8bf70ba2b70 (SUCCESS)>>]>
```

Filter on the `status` and show the `task_args` and `traceback` of the failed task

```python
>>> task = TaskResult.objects.filter(status='FAILURE').first()
>>> task.task_args
'"(\'10\',)"'
>>> task.traceback
'Traceback (most recent call last):\n  File "/home/jackevans/.local/share/virtualenvs/blog-ZV8xlUiZ/lib/python3.10/site-packages/celery/app/trace.py", line 451, in trace_task\n    R = retval = fun(*args, **kwargs)\n  File "/home/jackevans/.local/share/virtualenvs/blog-ZV8xlUiZ/lib/python3.10/site-packages/celery/app/trace.py", line 734, in __protected_call__\n    return self.run(*args, **kwargs)\n  File "/home/jackevans/code/blog/blog/celery.py", line 28, in square\n    return n * n\nTypeError: can\'t multiply sequence by non-int of type \'str\'\n'
```


## Next Time

This concludes part 2, in part 3 we'll explore triggering periodic celery tasks
and integrating this with django using the `django-celery-beat` package.
and monitoring.

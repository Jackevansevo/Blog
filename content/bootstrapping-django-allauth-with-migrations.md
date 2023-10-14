Title: Bootstrapping django-allauth with migrations
Date: 2022-08-06
Status: published
Tags: Python, Django

Recently I added
[django-allauth](https://django-allauth.readthedocs.io/en/latest/index.html) to
my site, to enable logging in with third party auth providers (such as Google).


## Allauth docuemntation

As per the [installation
instructions](https://django-allauth.readthedocs.io/en/latest/installation.html#post-installation)
allauth recommends the following:

- Add a `Site` for your domain, matching `settings.SITE_ID` (`django.contrib.sites` app).
- For each OAuth based provider, either add a `SocialApp` (`socialaccount` app) containing the required client credentials, or, make sure that these are configured via the `SOCIALACCOUNT_PROVIDERS[<provider>]['APP']` setting (see example above).

## Django documentation

According to the [Django documentation](https://docs.djangoproject.com/en/4.0/ref/contrib/sites/#enabling-the-sites-framework)

`django.contrib.sites` registers a `post_migrate` signal handler which creates
a default site named `example.com` with the domain `example.com`. This site
will also be created after Django creates the test database. To set the correct
name and domain for your project, you can use a [data migration](https://docs.djangoproject.com/en/4.0/topics/migrations/#data-migrations).

## The problem

The default `example.com` site isn't particularly useful default when working
with the `allauth` package.

This configuration requires you to manually head into the admin to:
- Create a new site for `localhost:8000` (or however you're developing locally)
- Create a new `SocialApp` for each provider (`google` in my case) along with
  respective secrets, then link to your created site

This is required every time you have to bootstrap your environment, i.e. when
cloning the project on a new machine, or after wiping your DB.

I wanted a mechanism to be able to quickly bootstrap my project during
development across machines with minimal manual intervention.

The docs indicate a
[migration](https://docs.djangoproject.com/en/4.0/topics/migrations/#module-django.db.migrations)
can be used to set a *correct name and domain for your project* but doesn't
specify how.


## Solution

After a bit of googling I came up with:

```python
from django.conf import settings
from django.contrib.sites.models import Site
from django.db import migrations


def create_site(apps, schema_editor):
    if settings.DEBUG:
        site = Site.objects.create(name="localhost", domain="localhost:8000")


class Migration(migrations.Migration):

    dependencies = [
        ("feeds", "0001_initial"),
        ("sites", "0002_alter_domain_unique"),
    ]

    operations = [migrations.RunPython(create_site)]
```

`feeds` is the name of the app I'm developing, and `sites` refers to the
builtin `django.contrib.sites` app (added to `INSTALLED_APPS`). By specifying
these as dependencies this ensures the migration is ran only once these have
completed.

**Note** it's possible to manually create blank migrations on a per app basis (not from models) with: 

    ./manage.py makemigrations <app> --empty

---

This alone isn't sufficient to bootstrap a working project with
allauth. Allauth still requires an additional `SocialApp` integration to be
created and linked to your site.

Fortunately this is fairly trivial to extend:

```python
import os

from allauth.socialaccount.models import SocialApp
from django.conf import settings
from django.contrib.sites.models import Site
from django.db import migrations


def create_site(apps, schema_editor):
    if settings.DEBUG:
        site = Site.objects.create(name="localhost", domain="localhost:8000")
        social_app = SocialApp.objects.create(
            provider="google",
            name="google",
            client_id=os.environ.get("GOOGLE_CLIENT_ID"),
            secret=os.environ.get("GOOGLE_CLIENT_SECRET"),
        )
        social_app.sites.set([site])


class Migration(migrations.Migration):

    dependencies = [
        ("feeds", "0001_initial"),
        ("sites", "0002_alter_domain_unique"),
        ("socialaccount", "0001_initial"),
    ]

    operations = [migrations.RunPython(create_site)]
```

By storing the secrets as environment variables I can provide a `secrets.env` file (that's ignored by version control) with the following values:

```env
GOOGLE_CLIENT_ID="****"
GOOGLE_CLIENT_SECRET="****"
```

If I clone the project on a new machine (or want to wipe my DB volume and start
over) I can quickly bootstrap my project with:

```
$ ./manage.py makemigrations
$ ./manage.py migrate
```

And Google login (via allauth) should work out of the box.

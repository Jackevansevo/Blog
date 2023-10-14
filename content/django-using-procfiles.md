Title: Django - Manage Multiple Processes with Procfiles
Date: 2022-09-25
Status: published
Tags: Python, Django

## Backstory

I have a little feedreader Django application that I run on fly.io. This primarily consists\* of:
- a Django app (a couple gunicorn workers) that serves the main app
- a celery worker (to asynchronously update the feeds)
- a celerybeat process (to periodically triggers the scraping task)


Previously I was spinning up one new VM instance per process, this caused x2 issues:

1. I had a pretty complex docker-compose setup to emulate this locally.
2. This resulted in some unnecessarily high billing for what is in reality a
   tiny service.

![Mr Krabs money](https://static.fandomspot.com/images/11/10476/00-featured-mr-krabs-counting-money-screenshot.jpg)

\*Alongside this I also run:
- a sqlite volume
- a redis instance (my celery task broker)

Recently I wanted to simplify things a little and scale back the number of VMs
I was running, by configuring Django + celery to coexist on a single instance.

## (Re)-Discovering Procfiles


Reading the fly.io documentation for [Running Multiple Processes Inside A
Fly.io App](https://fly.io/docs/app-guides/multiple-processes/) they
recommended using a [Procfile
Manager](https://fly.io/docs/app-guides/multiple-processes/#use-a-procfile-manager).
One of the Procfile managers they recommend is
[overmind](https://github.com/DarthSim/overmind), so I decided to give this a
go.

I first remember using Procfiles back when I started my developer journey
deploying apps to Heroku 🪦

Then for whatever reason, suddenly tooling like docker and minikube seemed to
take over the world and suddenly the dev experience started to get pretty
complicated.

## Using Overmind

It was pretty refreshing to replace a bunch of separate containers and their
respective Dockerfile scripts with the following:

```
app: gunicorn --bind 0.0.0.0:8080 feedreader.asgi:application -k uvicorn.workers.UvicornWorker
celery: celery -A feedreader worker -l info -E
beat: celery -A feedreader beat -l info -S django
```


As a bonus, overmind supports using `Procfile.dev` during local development
This nicely replaces a lot of the docker-compose cruft I'd accumulated to run
my app locally:

```
app: ./manage.py runserver
beat: celery -A feedreader beat -S django -l INFO
celery: watchfiles 'celery -A feedreader worker -l INFO -E' --ignore-paths db.sqlite
```

## Developing

During local development I start my entire project with `overmind s -D`, which
will run overmind in the background (as a demonized process).

This starts all the processes I need at the same time with a single command.

When it comes to debugging or viewing the logs I'll connect to overmind with:

`overmind c`

This will attach me to a tmux session for my project, with one pane per
process.

Here's an example below:

<video controls class="w-100">
  <source src="https://user-images.githubusercontent.com/4996338/192102128-c04169e9-48a9-4c30-985f-1346501be753.mov" type="video/webm" />
</video>

## Advantages 📈

- It's faster and more convenient than opening up x3 terminal tabs/splits/processes and starting each process manually by hand
- It integrates nicely with tmux, a technology I was already comfortable with, so supplements my existing workflow
- Is much simpler than using docker + docker-compose

## Disadvantages 📉

Unlike docker this setup isn't 100% portable to another machine / development
environment. Instead some initial setup is required.

For example: Python dependencies have to be installed locally and redis has to
be configured on the host.

It's not quite as seamless as running `docker-compose up` and everything
magically working first time. But given it's just me contributing + working on
my little personal project, this feels like an acceptable trade-off

Title: Python gracefully detaching debuggers from running containers 🐍🐳🪳
Date: 2022-07-08
Status: published
Tags: Python, Docker

## Problem

Lets say you have a simple service you want to debug that's running in a docker container. So you add a `breakpoint()` to the relevant code:


```python
def index(request):
    entries = Entry.objects.all()
    breakpoint()
    return render(request, "feeds/index.html" {"entries": entries})
```

You trigger this logic in your service, and attempt to attach to your running container:


    docker attach my-service


And the breakpoint gets hit:

```
> /app/feeds/views.py(133)index()
    132     breakpoint()
--> 133     entries = Entry.objects.all()

ipdb> c
```


At this point you want to end your debugging session and gracefully detach from the attached process without killing the parent container.

So you attempt to hit `<Ctrl+c>` to exit the debugger how you normally would.

But this kills your service ... (forcing you to manually restart)

```
❯ docker ps -a
CONTAINER ID   IMAGE               COMMAND                  CREATED
1f45e69a2836   my_service      "python manage.py ru…"   2 hours ago   Exited (0) 20 seconds ago                                      feedreader_app_1
```

<br>

![Dead Docker](https://leoh0.github.io/images/dead_docker.png)


## Solution

Recently I discovered you can specify an exit sequence:

    docker attach --detach-keys="ctrl-c" my_service


Now when you hit the `<Ctrl+c>` escape sequence in your debugger session the app will close as exepected

```
> /app/feeds/views.py(133)index()
    132     breakpoint()
--> 133     entries = Entry.objects.all()

ipdb> c
[08/Jul/2022 12:12:06] "GET / HTTP/1.1" 200 34757
read escape sequence
```

## Alternative

Or you can modify the `restart` policy of your service, e.g:

```
docker run -it -d --restart always my_service
```

For example I have the following in my `docker-compose.yml`

```yml
services:
  app:
    restart: always
    stdin_open: true
    tty: true
    command: python manage.py runserver 0.0.0.0:8000
    ports:
      - "8000:8000"
```

This way even if you trigger the `<Ctrl+C>` exit sequence in your attached container and kill the parent, the service will automatically restart.

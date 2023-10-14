Title: Per project IPython project history in docker compose
Date: 2022-07-13
Status: published
Tags: Python, Docker

A neat trick I learnt recently ([From this Github thread]([https://github.com/cookiecutter/cookiecutter-django/issues/1589))

It's possible to store IPython history persistently per project in a docker compose, i.e:

```diff
diff --git a/docker-compose.yml b/docker-compose.yml
index 043b004..7e6d029 100644
--- a/docker-compose.yml
+++ b/docker-compose.yml
@@ -18,7 +18,7 @@ services:
     volumes:
       - .:/app
+      - ipython_data_local:/root/.ipython/profile_default
     build:
       context: .
       target: dev
@@ -85,3 +85,7 @@ services:
     depends_on:
       - redis
       - db
+
+
+volumes:
+    ipython_data_local: {}
```

Previously I'd tried mounting ` ~/.ipython/profile_default/history.sqlite` but I found this per project solution to be much nicer.

Sidenote: the [cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django) repo has some really nice features (even if you're not using the template itself)

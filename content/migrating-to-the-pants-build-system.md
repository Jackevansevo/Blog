Title: Migrating to the Pants Build System
Date: 2023-01-18
Status: draft
Tags: Python

# Current Approach

At my workplace we maintain multiple different services. Often we'll want to
share common code between services, to facilitate this we keep various
libraries inside a top level `lib/` directory. This approach allows us to
easily share code between projects.

To manage dependencies each individual library/service maintains its own
`pyproject.toml` file declaring any dependencies required. These dependencies
are installed per project using [Poetry](https://python-poetry.org/).

When a service requires code from a library, we include the path to that
library in that services `pyproject.toml` file, here's a contrived example for
`services/example/pyptoject.toml`

```toml
[tool.poetry]
name = "example"

[tool.poetry.dependencies]
python = "^3.8"
"company.azure" = {path = "../../lib/azure", develop = true}
```

The corresponding `lib/azure/pyproject.toml` contains the following:

```toml
[tool.poetry]
name = "company.azure"
packages = [
    { include = "company" },
]

[tool.poetry.dependencies]
python = "^3.11"
azure-identity = "*"
"company.coms" = {path = "../../lib/coms", develop = true}
```

Note: we can chain together dependencies, so `service/example` depends on
`lib/azure` which in term depends on `lib/coms`.

Altogether the (simplified) directory structure shown from the repository root
might look something like:

```
.
├── lib
│  ├── azure
│  │  ├── company
│  │  │  └── azure
│  │  │     └── __init__.py
│  │  ├── poetry.lock
│  │  └── pyproject.toml
│  └── coms
│     ├── company
│     │  └── coms
│     │     └── __init__.py
│     ├── poetry.lock
│     └── pyproject.toml
└── services
   └── example
      ├── main.py
      ├── poetry.lock
      └── pyproject.toml
```

We can see `services/example` has access to the `lib/azure` and any of its sub
dependencies by running the following:

```shell
➜  example git:(main) poetry show company-azure
 name         : company-azure
 version      : 0.1.0
 description  :

dependencies
 - azure-identity *
 - company.coms *
```

We can use built in Poetry tools to determine why certain dependencies are included:

```
➜  example git:(main) poetry show --why --tree company-coms
company-azure 0.1.0
└── company-coms *
    └── requests *
        ├── certifi >=2017.4.17
        ├── charset-normalizer >=2,<4
        ├── idna >=2.5,<4
        └── urllib3 >=1.21.1,<1.27
```

We can verify everything is working by importing from these packages, as well
as importing any sub-dependencies of each package (known as transitive
dependencies):

```python-shell
>>> import company.azure
>>> company.azure.__version__
'0.1.0'
>>> from azure import identity
>>> identity.__version__
'1.12.0'
```

Inspecting `sys.path` shows what's going on:

```shell
➜  example git:(main) poetry run python -i main.py
hello world
```

```python-shell
>>> import sys
>>> import pprint
>>> pprint.pprint(sys.path)
['/home/jackevans/code/example/services/example',
 '/home/jackevans/.pyenv/versions/3.11.1/lib/python311.zip',
 '/home/jackevans/.pyenv/versions/3.11.1/lib/python3.11',
 '/home/jackevans/.pyenv/versions/3.11.1/lib/python3.11/lib-dynload',
 '/home/jackevans/.cache/pypoetry/virtualenvs/example-fpnVLQHn-py3.11/lib/python3.11/site-packages',
 '/home/jackevans/code/example/lib/azure',
 '/home/jackevans/code/example/lib/coms']
```

In summary, using the `"company.azure" {path = "../../lib/azure"}` directive
allows us to import code from `lib/azure` in `services/example` as if that
package lived inside our service.

# Downsides Of This Approach

This approach serves us well, but has a few trade-offs.

## No Automation

Unfortunately the process of including library code isn't automatic, you can't
reference local library code without first specifying it in the services
`pyproject.toml` file. Likewise, if we no longer use a library and forget to
remove this declaration, its code (and dependencies) will still be include.

Because there's no concept of tree shaking (i.e. detecting and removing unused
packages), we have to carefully manage our dependencies to prevent unwanted
packages ending up in our deployment artifacts. To work around this we specify
[optional](https://python-poetry.org/docs/pyproject/#extras) dependencies. This
is useful in scenarios where a library only requires a package under certain
conditions.

## Isolated Islands

In a sense each library or project is it's own isolated island. Although
libraries might know about each other, there's no repo wide picture of the
world.

Consequently performing common operations like, running tests, upgrading a
dependency or running a linter have to be ran on a service by service basis. To
combat this, we maintain some custom tooling that enables these operations to be
carried out repo-wide.

Due to our repository structure, Poetry workflow and associated import syntax
it's impossible to run commands at the project root, i.e. `python` or `pytest`.
Instead commands have to run from each individual Poetry project. Consequently
we have to maintain custom tooling to bulk test/build and deploy our services.

![Each package is its own island](https://media.istockphoto.com/id/1050232806/vector/vector-illustration-set-of-different-scenes-of-tropical-islands-with-palm-trees-and.jpg?s=612x612&w=0&k=20&c=tKGaV_tnyw2d1jBMsjvCNhyR2tidOd3Qif0nhldjl3U=)

## Editor Tooling

Because each service/library

> TODO Finish this section

These aforementioned mismatches also degrade the editor tooling experience as
it's difficult for intellisense/LSP/other tools to know which version to use
when a developer is jumping between projects within the repo.

## Explicit Build Step

In the earlier example demonstrating reference relative paths, Poetry handles
everything fine during development, but in order to deploy services we require a
separate build step to copy directories that mirrors this behaviour. Once the
build step is complete, our directory structure looks as follows:

```
services/example
├── company
│  ├── azure
│  │  └── __init__.py
│  └── coms
│     └── __init__.py
├── main.py
├── poetry.lock
└── pyproject.toml
```

We have some additional tooling to build and test each service/library. This
starts by traversing the entire repository and running `poetry install`.
Unfortunately can be quite slow as dependencies potentially have to be
resolved/installed multiple times.

## 'Version Drift'

Because each service/library has it's own `pyproject.toml` and `poetry.lock` it
can sometimes be difficult to keep dependencies consistent across the
repository.

Various services/libraries had been created at different times, E.g. some
services might specify `Blah = "^2.0.0"` in their `pyproject.toml`. However the
lockfile for ServiceA might contain `Blah==2.0.0` whereas another lockfile for
ServiceB created at a later date might contain a newer version `Blah==2.2.3`.

If lockfiles aren't regularly updated in a uniform fashion this can lead to
dependencies getting out of sync across the repo. With different services having
conflicting ideas of what locked version to use for the same dependency.

In a worst scenario this "version drift" can make it tricky to determine which
services are affected by certain bugs.

---

# Evaluating Pants

We wanted to explore and see if there was any better tooling out there to
manage this kind of workflow. I'm an avid listener of the [Talk Python To Me
Podcast](https://talkpython.fm/) where they recently aired an
[episode](https://talkpython.fm/episodes/show/387/build-all-the-things-with-pants-build-system)
about [Pants](https://www.pantsbuild.org/).

The conversation on the podcast immediately struck a chord, many of the
features pants offered were things we'd struggled with.

According to the [Pants documentation](https://www.pantsbuild.org/docs)

> Pants installs, orchestrates and runs dozens of standard underlying tools -
> compilers, code generators, dependency resolvers, test runners, linters,
> formatters, packagers, REPLs and more - composing them into a single stable,
> hermetic toolchain, and speeding up your workflows via caching and
> concurrency.

Having a single tool that could format, lint and run tests across the entire
repository alone would already be an improvement over the custom tooling that
we maintian.

So after some initial reading and research I quickly decided to try a proof of
concept adopting pants in our repo.

Aside: The name 'pants' makes us chuckle at my workplace, in British English
'pants' means 🩲 (underwear) not the American English equivalent of 👖.

## Step 1 - Pre-Requisite (Resolve Version Madness)

From my research into pants, a common community recommendation is to strive
towards a [single lockfile
](https://www.pantsbuild.org/docs/python-third-party-dependencies#multiple-lockfiles).
The only exception to this rule being where a service explicitly requires a
different version of a dependency. In this specific service can have it's own
separate lockfile.

To make adopting pants easier, I figured it would be a good first step to make
sure our dependencies in both `pyproject.toml` and `poetry.lock` were consistent
across the repo.

![All Services Agreeing What Dependency Version To Use](https://cdn11.bigcommerce.com/s-jyvxk5hzsq/images/stencil/1280x1280/products/5040/43025/5327L__83797.1539347627.jpg?c=2)

In order to create a single unified lockfile it was a useful starting point to
eliminate any differences and try to enforce (as close to) identical versions
across the board.

Taking our earlier example, (i.e. ServiceA includes Blah==2.0.0 in its lockfile,
and ServiceB includes Blah==2.2.3). If the author of our third party library
above is a good citizen, then we should (in theory) be able to use later version
of our dependency (2.2.3) for both serviceA and serviceB.

However there's no guarantee things will just work⟨™⟩ if we choose to upgrade.
So it was vital that were upgraded these dependency incrementally, uniformly
upgrading individual dependencies across the repo to be consistent and testing
as we went along to ensure nothing was broken.

In more extreme cases, services might not even agree what major version of a
dependency to use i.e. `Blah = "^2.0.0"` vs `Blah = "^1.0.0"`, in which case
more leg work might be required to upgrade to the latest major version, as
breaking changes are likely to be involved.

To achieve this we wrote some tooling to identity where we had miss-matched
dependency versions across the repo. This tool simply traversed each
service/library, looked in each `pyproject.toml` file, recorded what it found
for each then dumped the output of each dependency across all projects.

A simplified version of this tool is shown below:

```python
all_deps = defaultdict(lambda: defaultdict(list))

for file_path in poetry_files:
    with open(file_path) as f:
        parsed = toml.load(f)
        parsed_deps = parsed['tool']['poetry']['dependencies']
        for dep, info in parsed_deps.items():
            if dep == 'python' or dep.startswith('company.'):
                continue
            all_deps[dep][info].append(f.name)

for dep, versions in all_deps.items():
    if len(versions) > 1:
        print(f'Found multiple versions of {dep}')
        for version, usages in versions.items():
            for usage in usages:
                print(version, 'in', usage)
```

The same tool could be used to check both `pyproject.toml` files and
`poetry.lock` files. Once we'd identified where we had version mismatches, we
could go in and update the `pyproject.toml` files, and update lockfiles where
appropriate until versions were consistent across all projects.

## Step 2 - One Lockfile to Rule Them All

Pants is actually able to consume any `poetry.lock` files created by Poetry, but
I decided I would abandon these in favour of using the lockfiles generated by
pants instead. The pre-requisite work to update/align all the `poetry.lock`
files would still be useful if my POC wasn't adopted.

Now, with dependency versions consistent across the repo, if multiple services
each depend on the same dependency, and all declare an identical version of it
in their `poetry.lock`. We could extract this dependency to a global
`pyproject.toml` and have each service refer to this global version instead, and
then remove the original duplicates.

![One Lockfile to Rule Them All](https://glampinghub.com/blog/wp-content/uploads/2021/02/The-One-Ring-to-Rule-Them-All.jpg)

Once we've recorded all the 'global' dependencies (dependencies used more than
once) into a shared location, we can again traverse all the `pyproject.toml` and
remove any dependencies already referenced in our globally scoped lockfile,
alongside removing any `pyproject.toml` files that don't have any unique
dependencies left to declare.

In theory once we're done, we should be able to run `./pants generate-lockfiles`
to create one single lockfile, and then run `./pants export ::` to create a
single virtual-environment containing all the third party dependencies across
the entire project.

```python

dependency_occurrences = defaultdict(list)
project_info = {}

# 'Collection' stage
for location in pyproject_files:
    # Ignore root pyproject.toml
    if location == "pyproject.toml":
        continue

    with Path(location) as pyproject:
        data = toml.load(pyproject)

        project_deps = {}

        for dep, info in data["tool"]["poetry"]["dependencies"].items():
            if dep.startswith("company."):
                continue
            project_deps[dep] = info
            dependency_occurrences[dep].append(version)

        poetry_section = data["tool"]["poetry"]

        # Only keep a subset of the original pyproject.toml
        project_info[pyproject] = {
            "tool": {
                "poetry": {
                    "dependencies": project_deps,
                }
            }
        }

# 'Resolver' stage
for pyproject, data in project_info.items():
    deps = data["tool"]["poetry"]["dependencies"]
    unique_deps = {}
    for dep, version in deps.items():
        if len(dependency_occurrences[dep]) == 1:
            unique_deps[dep] = version

    if unique_deps == {}:
        # If a project has no unique dependencies
        # delete the pyproject.toml file
        pyproject.unlink()
    else:
        data["tool"]["poetry"]["dependencies"] = unique_deps
        pyproject.write_text(toml.dumps(data))
```



## Step 3 - Code Transformation

With dependencies organised, the next step to adopt pants was to make all
library imports absolute instead of relative.

Recall, with Poetry: using the `"company.azure" {path = "../../lib/azure"}`
directive allowed us to import code from `lib/azure` in `services/example` using
the `company.azure` namespace.

With Pants, the toolchain expects commands to be executed from the project root,
and import paths to be absolute. This meant we'd have to type `from
lib.azure.company.azure`. Furthermore the disjointed structure separates the
`pyproject.toml` file from the actual library contents.

Because this nested directory hierarchy was no longer necessary I decided to
flatten the repository, moving any nested library code closer to the project
root.

Recall this is what our directory structure looked like before:

```
.
├── lib
│  ├── azure
│  │  ├── company
│  │  │  └── azure
│  │  │     └── __init__.py
│  │  ├── poetry.lock
│  │  └── pyproject.toml
│  └── coms
│     ├── company
│     │  └── coms
│     │     └── __init__.py
│     ├── poetry.lock
│     └── pyproject.toml
└── services
   └── example
      ├── main.py
      ├── poetry.lock
      └── pyproject.toml
```


I wrote another script (again the real thing was more comprehensive) that
essentially performed the following code transformation across the repository.

```shell
➜  example git:(main) mv lib/coms/company/coms/* lib/coms
➜  example git:(main) rm -r lib/coms/company
➜  example git:(main) mv lib/azure/company/azure/* lib/azure
➜  example git:(main) rm -r lib/azure/company
```

After the code transformation step:

```
.
├── lib
│  ├── azure
│  │  ├── __init__.py
│  │  ├── poetry.lock
│  │  └── pyproject.toml
│  └── coms
│     ├── __init__.py
│     ├── poetry.lock
│     └── pyproject.toml
└── services
   └── example
      ├── main.py
      ├── poetry.lock
      └── pyproject.toml

```

We no longer required nested `company` folders for every library (i.e.
`lib/azure/company/azure -> lib/azure`).

After flattening the repository, I had to go through and rename any existing
imports accordingly, to match the new repository layout. This involved a lot of
find-and-replace using `sed`:

```
sed -i 's/company\.\(\w\+\)/lib.\1/' $(egrep -r -l "company\.\w+" services lib)
```

This snippet replaces occurrences of `company.<word>` with `lib.word` across the
repo.

There's a possibility this entire stage could have been avoided if I'd just been
creative and renamed `lib` -> `company` instead. But I wanted to keep the `lib`
folder to avoid confusion.


## Step 3 - Putting on Pants 👖

With the dependencies organised, our repository structure flattened, and imports
transformed, we were ready to try Pants.

The first stage was to run the following:

```
./pants tailor ::
```

This runs some static analysis tool that scans your repo and automatically
creates Pants Build files in each directory based on heuristics checking the
contents.

I.e. if a directory contains a `pyproject.toml` file with Poetry dependencies.
The tool will automatically create a build file with the following contents:

```
python_sources()

poetry_requirements()
```

These build files provide some build time information for Pants, informing it on
the state of the repository.

```
./pants generate-lockfiles
```

And then:

```
./pants export
```

# Results

We were fortunate as we could generate a single lockfile for the entire project.
We didn't have any instance where service A specifically depended on a
newer/later version of the same dependency as used by service B or C. In this
scenario I believe you'd have to create a separate lockfile for service A.

We can generate a single virtual environment which contains all the possible
dependencies across the project.

We can run tests in parallel against the entire repository. Services with tests
that require databases setup/tear-down are batched into the same pytest process
and have access to a unique database name.

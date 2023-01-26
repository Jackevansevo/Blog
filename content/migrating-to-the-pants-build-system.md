Title: Migrating to the Pants Build System
Date: 2023-01-18
Status: draft
Category: Python, Programming
Tags: Python


## Background

At my workplace we maintain multiple different services, each of which lives in
a `services/` directory. Often we'll want to share common code between services,
to enable this we have various libraries inside a top level `lib/` directory.
This approach allows us to easily share code between projects.

To achieve this each separate library/service has its own `pyrpoject.toml` file
declaring the dependencies required. These dependencies are installed per
project using `poetry`. In order to run or test a service or library locally
you first have to install all the dependencies for that project.

We have some additional tooling to build and test every service/library. This
starts by traversing the entire repository and running `poetry install`.
Unfortunately can be quite slow as dependencies potentially have to be
resolved/installed multiple times per library/service.

Using `poetry` when one service requires code from a library we can reference
that code locally, here's a contrived example for an imaginary service
`services/example/pyproject.toml`:

```
[tool.poetry.dependencies]
python = "^3.8"
"company.auth" = {path = "../../lib/auth", develop = true, extras = ["sql"]}
"company.azure" = {path = "../../lib/azure", develop = true}
"company.coms" = {path = "../../lib/coms", develop = true}
"company.webapp" = {path = "../../lib/webapp", develop = true, extras = ["tasks"]}
"company.utils" = {path = "../../lib/utils", develop = true, extras = ["secrets"]}
```

When deploying that service we have a separate build step that ...

## Exploring Monorepo Tooling

We wanted to explore some options to see if there was any better tooling out
there to manage this kind of workflow.

# Aims

- Ideally we want to generate a single lock-file
- Dependencies that are shared across multiple projects will live in a single global `pyproject.toml` at the root of the repository
- Any unique dependencies per project will remain inside the `pyproject.toml` file for that project
- Projects with no unique dependencies can safely have `pyproject.toml` removed

# Step 1 - Pre-Requisite

Because various services/projects had been created at different times, the
pinned lockfile versions across the repo were not necessary in sync. To later
combine shared dependencies into a single unified lockfile it would be a useful
starting point to ensure that these versions were consistent across the board.

The first step here was to write some tooling to identity where we had
miss-matched dependency versions across the monorepo. This tool simply traversed
the entire repo, looked within each project, collected dependencies together and
then dumped the output of each dependency across all projects.

I wrote the tool to check both `pyproject.toml` files and `poetry.lock` files.
Once we'd identified where we had version mismatches, we could go in and update
the `pyproject.toml` files, and update lockfiles where appropriate until
versions were consistent across all projects.


# Step 2 - Find common dependencies

# Step 3 - Clean Up

# Step 4 - Code Transformation

This stage involved a lot of find and replace, flattening the repository and
renaming imports to match the reflect the new repository structure.

There's a possibility this stage could have been avoided completely by editing
some stuff in pants. However, this path manipulation can over interfere with
other tooling. So the preferred option was to rename imports.

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

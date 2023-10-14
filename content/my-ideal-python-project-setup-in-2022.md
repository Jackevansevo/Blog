Title: My Ideal Python Project Setup in 2022
Date: 2022-05-19
Status: published
Tags: Python

![The world if everyone Python project used Black/Isort/Mypy](https://i.kym-cdn.com/entries/icons/mobile/000/026/738/future.jpg)

Unlike newer languages like Rust or Go which provide opinionated tooling out of the box, Python leaves a lot of those decisions up to the community. There's a plethora of options out there for type-checking, linting, dependency management and testing. Sometimes the amount of choice might feel overwhelming. Thankfully the community appears to have rallied around a common set of standard packages.

Here's my attempt at a non exhaustive list of everything I'd consider adopting for any greenfield Python project at the time of writing (2022). Disclaimer: this is just my opinion (formed from my experience writing software), your own opinions might differ.

## [Black](https://black.readthedocs.io/en/stable/)

Life is too short to argue about code formatting preferences. During code review, any discussions surrounding formatting detract from the purpose of the review itself. With that said, I'm thankful the wider Python programming community has settled on Black as the defacto standard.

Golang was the first major language I encountered that embraced code-autoformatting by default with `gofmt`. A common mantra heard in this community is: *"Gofmt's style is nobody's favourite, but gofmt is everybody's favourite."*. I feel the exact same could be said for Black.

A few other code-formatting tools exist (e.g: `yapf`, `blue`), I don't care which one you pick,  as long as it eliminates squables over manual code formatting. I recommend `black` purely because of it's popularity in the Python community. If a contributor complains you're using X formatter instead of Y, they're kind of missing the point.

If you're using `black` alongside `flake8` remmeber to read the documentation for [using black with other tools](https://black.readthedocs.io/en/stable/guides/using_black_with_other_tools.html#flake8)

```
[flake8]
max-line-length = 88
extend-ignore = E203
```

## [Isort](https://pycqa.github.io/isort/)

Despite a few [open issues](https://github.com/psf/black/issues/333) on the GH issue tracker Black doesn't yet support sorting imports.

I've found sorting imports (particularly breaking imports across multiple lines) can sometimes increase the amount of diff-noise in a Pull Request. 

Using `isort` alongside `black` might cause a few conflicts. To use both tools alongside each other refer to [https://pycqa.github.io/isort/docs/configuration/black_compatibility.html](https://pycqa.github.io/isort/docs/configuration/black_compatibility.html)

Usually I just add the following to my `setup.cfg`

```
[isort]
profile=black
```

## [Mypy](https://mypy.readthedocs.io/en/stable/)

Mypy is a static type checker for Python. Adopting static type checking can help identify bugs in your code, preventing an entire category of possible runtime errors in your code. For this reason I'd strongly recommend any greenfield Python project to adopt mypy (or another static type checking tool) in some capacity. 

For an excellent case study I highly recommend you read: [Tests aren’t enough: Case study after adding type hints to urllib3](https://sethmlarson.dev/blog/tests-arent-enough-case-study-after-adding-types-to-urllib3)

That being said type checking may not be appropriate in certain situations, i.e. when writing short-scripts, throw away code or quick prototypes. So use your better judgement. One of the major benefits (and arguably also a shortcoming) of `mypy` and gradual type checking is you get  to choose the extent to which you type-check your code, using type-hints and static analysis only where necessary.

Not specifically related to `mypy` itself, but one of the surprising benefits I've found from adding [type annotations](https://docs.python.org/3/library/typing.html) to code is that (depending on your editor) it greatly improves auto-complete suggestions. Additionally I've found type-annotations can (in some cases) improve the readability of code. This can be useful in a collaborative environment where you're frequently reading code written by other developers.

So even if you're not type-checking your code with a tool like `mypy`, you may wish to sprinkle your code with type annotations for these benefits alone.

## [Pre-commit](https://pre-commit.com/)

I've integrated most of the aforementioned tools in my text-editor. My code typically gets automatically formatted on save and linter/type-checking errors are displayed inline. If you use something like Pycharm or VSCode, this is pretty much the norm. This can help catch most type/linting/formatting issues during development.

However, its important to realize that not everyone writes code this way. Some might not have configured their editor appropriately or prefer to disable these rules, others might use editors that don't provide this kind of functionality.

Even with fancy editor tool integrations, sometimes errors slip through the cracks. If we're lucky these errors might get caught in CI. But wouldn't it be better to catch these errors before pushing code up to our remote git server?

In other circumstances, sometimes it's not practical to have scripts constantly running on file change. Particularly if those scripts are slow or expensive to run (i.e. tests or type-checking). One example that springs to mind is using `vulture` to check for dead code in your project.

![Git hooks](https://miro.medium.com/max/450/1*bAJrSit_8HoM5sy7ydw0zw.png)


For this reason, I find it incredibly useful to have tests, formatters & linting rules can as part of a git pre-commit hook (in edition to check integrated with my editor). 

This way myself (and other developers) can catch errors locally (before pushing to the remote) independent of what editors we're using.

The great thing about `pre-commit` is that it's entirely opt-in. Only developers that wish to enable it per project will be effected. Not every developer will find this kind of tooling useful in their personal developer workflow, this way we're not forcing arbitrary rules/conventions down peoples throats.

## [Pytest](https://docs.pytest.org)

I suppose this boils down to personal preference more than anything else in this list. I personally prefer how `pytest` tests feel like they generate less boiler plate. Conceptually I also find it much easier to share fixtures across tests than group related tests by class. 

One of the great things with pytest is it's completely compatible with `unittest`, so you can simply use `pytest` as a test-runner for your existing test-suite without having to re-write anything.

## [Poetry](https://python-poetry.org/) vs [Pipenv](https://pipenv.pypa.io/en/latest/) ???

![Jakie Chan What](https://i.pinimg.com/originals/c1/3a/2b/c13a2b2e10855bffdc014f121c5eff7e.jpg)

Weirdly the community doesn't appear to have quite settled on one favoured dependency management solution. I've used both in the past and found both to be perfectly reasonable solutions.

I've also had success using [jazzband/pip-tools](https://github.com/jazzband/pip-tools) within project virtual environments to compile and pin dependencies

I won't recommend a specific tool here. Any choice is fine providing you do the following:
- Lock/pin your dependencies
- Have a mechanism to easily graph, upgrade and audit your dependencies 
- Distinguish and split between your dev and prod dependencies (optimization)


# Personal tools

There's a few things that I personally like to include (for my own use) when working on Python projects.

## [Dirnev](https://direnv.net/)

Using Direnv enables you to automatically activate python virtual-environments when you enter a new directory, eliminating the need to manually activate/deactivate virtual environments per project.

Direnv is flexible and unopinionated about the specifics of virtualenv management, supporting `pipenv`, `poetry` and `virtualenv` out of the box. This flexibility should makes it more than suitable for most projects.

## [Ipython](https://ipython.org/) & [ipdb](https://pypi.org/project/ipdb/)

This one is another no-brainer (if not already installed). Setting ipdb (ipython-debugger) as the default debugger for Python gives a much better experience over the default `pdb`. I like to make this the default by setting the builtin `PYTHONBREAKPOINT` environment variable.

I couple this with `direnv` (above) to automatically export the variable per project by including the following setting in my `.envrc`

    export PYTHONBREAKPOINT=ipdb.set_trace

This works great for me but if you're using alternatives like the Pycharm builtin debugger then this approach won't be necessary.

Title: Direnv: Fix missing virtualenv shell prefix
Date: 2023-02-23
Status: published
Tags: Python, Shell

Something minor I came across today.

I like to use a tool called [direnv](https://github.com/direnv/direnv), I'm
also currently using [zsh](https://www.zsh.org/) as my shell of choice (with
[ohmyzsh](https://ohmyz.sh/).

Day to day I write a lot of Python, so I use direnv to automatically activate
(or create) python virtual environments when I navigate into certain
directories. See an example:

## Current Behaviour

```shell
cd blog
direnv: loading ~/code/blog/.envrc
direnv: export +VIRTUAL_ENV ~PATH
➜  blog git:(main) ~ echo $VIRTUAL_ENV
/home/jackevans/code/blog/.direnv/python-3.11.1
```

At a glance it's difficult to tell whether my current shell currently
has a `$VIRTUAL_ENV` activated or not.

## Desired Behaviour

If I manually source a virtualenv, the behaviour is slightly different, instead
my prompt will show a prefix `(python-3.11.1)`

```shell
➜  blog git:(main) ~ direnv deny
direnv: error /home/jackevans/code/blog/.envrc is blocked. Run `direnv allow` to approve its content

➜  blog git:(main) ~ source .direnv/python-3.11.1/bin/activate
(python-3.11.1) ➜  blog git:(main) ~ deactivate
```

## The Fix

I came across [this
thread](https://stackoverflow.com/questions/52437468/activating-virtualenv-with-direnv-doesnt-activate-virtualenv)
which pointed me to the official [direnv
documentation](https://github.com/direnv/direnv/wiki/Python#restoring-the-ps1)

The solution is to place the [following snippet](https://github.com/direnv/direnv/wiki/Python#zsh) in your `.zshrc`

```zsh
setopt PROMPT_SUBST

show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1
```

Then enjoy your consistent virtualenv prompt:

```shell
➜  blog git:(main) source ~/.zshrc
(python-3.11.1) ➜  flitter git:(main)
```

<br>

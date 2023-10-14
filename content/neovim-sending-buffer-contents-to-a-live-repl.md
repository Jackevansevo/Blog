Title: Neovim: sending buffer contents to a live repl
Date: 2023-08-27
Status: published
Tags: Neovim

I was recently messing around with Clojure again solving some Advent of code
problems (as I sometimes do).

Whenever I'm using Clojure I try and leverage the power of the REPL and eval
stuff in my editor using
[tpope/vim-fireplace](https://github.com/tpope/vim-fireplace).

For fun, I wondered if I could use the neovim job control API to achieve a
super basic version of the same thing in Python.

I'm aware there's loads of plugins out there already achieve this but here's
what I came up with:

The first piece is an augroup to capture the latest terminal job id, (this was
easier than writing code to spawn a dedicated terminal and track the id)

```text
augroup Terminal
au!
au TermOpen * let g:last_term_job_id = b:terminal_job_id
augroup END
```

The next piece is a convenience command to launch a Python REPL for the current buffer:

```text
command Repl execute 'vsplit | term python -i %' | set syntax=python | execute "normal \<C-W>h"
```

Finally two bindings (normal mode and visual mode) to send either lines or
currently selected text to be evaluated in the REPL:

```text
nnoremap cpp "kyy \| :call jobsend(g:last_terminal_job_id, @k)<CR>
vnoremap cpp "kyy \| :call jobsend(g:last_terminal_job_id, @k . "\n")<CR>
```

Below is a video demonstration (Not too bad for ~10 minutes of confused googling).

<video class="w-100" controls>
    <source src="{static}/images/send-buffer-contents-to-repl.webm">
</video>

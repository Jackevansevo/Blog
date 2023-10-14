Title: A vim experiment: ditching fuzzy finders
Date: 2023-08-20
Status: published
Tags: Vim, Neovim

I recently revisited  [How to Do 90% of What Plugins Do (With Just
Vim)](https://www.youtube.com/watch?v=XA2WjJbmmoM). I love this talk (and
others like it) because it highlights just how much you can achieve just using
vim. These techniques might might not always be the best or most efficient way
to get things done, but a lot of the time, they're sufficient.

<div class="ratio ratio-21x9">
<iframe src="https://www.youtube.com/embed/XA2WjJbmmoM" title="How to Do 90% of What Plugins Do (With Just Vim)" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

<br>

I find a lot of newcomers to vim, who're learning the editor automatically
reach for plugins or even entire vim distributions without first learning how
the underlying tool works.

At this point I've been using vim for over a decade and I'm still learning
about functionality and refining my use of the tool.

I've always been aware of the builtin :find command but for as long as I can
remember I've always utilized some kind of fuzzy finder to open files.
Originally using [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) and
more recently with
[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

Last week I decided to conduct an experiment: If I uninstalled
[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim),
would I miss the fuzzy find functionality? Or could I survive (or even thrive)
by with the builtin :find and :grep commands.

<br>

## What I changed

I replaced the following telescope bindings

```
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
```

With their builtin counterparts:

```
vim.keymap.set('n', '<leader>f', ':find ', {})
vim.keymap.set('n', '<leader>/', ':grep ', {})
```

To make grep a bit more sane I also created the following convenience mapping:

```
vim.cmd([[ command! -nargs=+ Grep execute 'silent grep! <args>' | copen ]])
vim.keymap.set('n', '<leader>/', ':Grep ', {})
```

This prevents the annoying:

```text
Press ENTER or type command to continue
```

<br>

## Builtin :find vs fuzzy find

Fortunately the codebases I normally work on are relatively small, so I can get
away with locating the files I need using the builtin :find command.

The key I discovered to making the builtin :find more useless is to explicitly
let vim know which files in the repo you consider to be important. For some
projects this might mean manually altering the default path to something more
useful `set path=lib/*,services/*`.

For most projects I've found `set path=,,` to be sufficient.

Afterwards you'll want to set the `wildignore` to exclude any files you might not be interested in e.g:

```
set wildignore+=*.pyc,*/node_modules/*,*/__pycache__/
```

This ends up being fast enough for the kinds of repositories I'm dealing with,
but I can imagine this approach begins to falter when you're working on giant
repositories with thousands of files.

I think one of the appealing things about reaching for a tool like fzf or
telescope is they don't require any explicit configuration. If you're using
either tool in conjunction with ripgrep, your search results will respect
you're .gitignore file by default. Whereas with the builtin :find command
you'll have to repeat these patterns in wildignore.

I wish that similar to grepprg, there was a mechanism to configure an external
tool to use for executing find. This way you'd be able to extend the exsiting
:find without having to define a completely new command.

<br>

## Builtin :grep vs Telescope live grep

Abandoning telescopes live grep turned not to be much of a sacrifice. Typically
I'd use telescope to initiate a search, then use the key combination to
populate the quickfix list anyway.

The reason for doing this is that I'm already a heavy user of the plugin
[romainl/vim-qf](https://github.com/romainl/vim-qf) plugin, which allows me to
further refine search results present in the quickfix list. I like this
workflow, as it feels quite methodical to grep for something, then narrow down
the search results, instead of having to write ever more complicated grep
patterns.

The way I was previously using telescope to search this was is basically just
the builtin grep with extra steps. Occasionally it's handy to see live search
results appear along the way as I'm typing, but more often that not I found
it's just distracting noise.

I'd already configured `grepprg` to use as I'm
typing[ripgrep](https://github.com/BurntSushi/ripgrep) with:

```
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
```

Which is super fast and respects any .gitignored files by default.

The only minor annoyance I had was having to always quote any search with
spaces. I'm always forced to type

```
grep "class Thing"
```

Previously with Telescope, I'd just use the following mapping

```
nnoremap <leader>g <cmd>lua require('telescope.builtin').live_grep()<cr>
```

And then immediately start typing `class Thing` and see results immediately,
with no need to wrap my search query in quotes.

<br>

## Conclusion

Maybe you're like me and you don't work on giant codebases, in which case you
might be surprised how far you can get with the builtin :find and :grep
commands.

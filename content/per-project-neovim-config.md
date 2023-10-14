Title: Per Project Neovim Config
Date: 2022-11-16
Status: published
Tags: Neovim

I recently added the following snippet to my `init.lua` neovim config:

```lua
if vim.fn.filereadable('project_config.lua') == 1 then
  require('project_config')
end
```

Once I've got this file in place I can add per project keybindings. E.g.

```lua
vim.api.nvim_set_keymap('n', '<leader>tt', ':vsplit | term cd %:p:h:h; poetry run pytest --pdb -s -x --ff<CR>', { noremap=true, silent=false })
vim.api.nvim_set_keymap('n', '<leader>tf', ':vsplit | term cd %:p:h:h; poetry run pytest --pdb -s -x --ff %:p<CR>', { noremap=true, silent=false })
```

I like to bind `<leader>tt` and `<leader>tf` to quickly run tests. Placing this
configuration per project is useful here as the specifics of how tests are ran
can vary between projects.

## Security Risks 

I'm aware this is a potential security risk as I'm loading arbitrary code from
disk. In an ideal world I'd probably want to prompt first for approval, or have
a whitelist of safe directories (similar to direnv).


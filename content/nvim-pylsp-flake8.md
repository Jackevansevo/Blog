Title: Neovim pylsp flake8
Date: 2023-07-31
Status: published
Tags: Neovim, Python

I recently had a bit of a pain getting pylsp setup with flake8 so I'm
documenting how I did it for future reference.

Instead of putting neovim LSP configuration in my `init.lua` file, I like to
configure this per project. To do this I enable `exrc` with:

```lua
vim.opt.exrc = true
-- Or in .vimrc
set exrc
```

Then I create a new local `.nvim.lua` configuration file in my project containing the following (which isavailable in [gist form](https://gist.github.com/Jackevansevo/dfd08aaecf3e50ec3e9b1dcf352ee2ad)):

```lua
local lspconfig = require('lspconfig')
lspconfig.pylsp.setup{
  settings = {
    pylsp = {
      configurationSources = {"flake8"},
      plugins = {
        pycodestyle = {
          enabled = false
        },
        mccabe = {
          enabled = false
        },
        pyflakes = {
          enabled = false
        },
        flake8 = {
          enabled = true
        }
      }
    }
  }
}

vim.cmd [[autocmd BufWritePre *.py lua vim.lsp.buf.format({ async = true })]]
```

<br>

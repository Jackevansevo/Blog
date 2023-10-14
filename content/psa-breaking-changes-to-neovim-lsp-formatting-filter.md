Title: PSA: Breaking changes to neovim LSP formatting filter on nightly
Date: 2022-06-02
Status: published
Tags: Neovim

In case anyone else runs into the same issue.

I ran into an issue this morning installing the latest neovim nightly build: All my onsave formatting appeared to be broken 💥


```text
Error detected while processing BufWritePre Autocommands for "<buffer=1>":
Error executing lua callback: /home/jackevans/Dotfiles/nvim/init.lua:95: attempt to index local
 'client' (a function value)
stack traceback:
  /home/jackevans/Dotfiles/nvim/init.lua:95: in function </home/jackevans/Dotfiles/nvim/init.lua:94>
  vim/shared.lua: in function <vim/shared.lua:0>
  vim/shared.lua: in function 'tbl_filter'
  /usr/share/nvim/runtime/lua/vim/lsp/buf.lua:212: in function 'format'
  /home/jackevans/Dotfiles/nvim/init.lua:91: in function 'lsp_formatting'
```

It seemed to be blowing up in the following piece of Lua code in my `init.lua`

```lua
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(clients)
      -- filter out clients that you don't want to use
      return vim.tbl_filter(function(client)
	return client.name ~= "tsserver"
      end, clients)
    end,
    bufnr = bufnr,
  })
end
```

## Investigating

Instead of browsing Github issues / trawling forums this is probably something minor we can fix (right???)

Lets take look at the commit log to see if anything had changed recently around LSP formatting ...

```
[I] jackevans@Thinkpad ~/c/d/neovim (master)> git log --grep=lsp
```

Hmmm, [this commit](https://github.com/neovim/neovim/commit/fa3492c5f7645feb979c767046b6ff335ea9d6ca) looks suspucious

```
commit fa3492c5f7645feb979c767046b6ff335ea9d6ca
Author: Mathias Fussenegger <f.mathias@zignar.net>
Date:   Wed May 25 19:38:01 2022 +0200

    feat(lsp)!: turn format filter into predicate (#18458)

    This makes the common use case easier.
    If one really needs access to all clients, they can create a filter
    function which manually calls `get_active_clients`.
```


# The Fix


After a quick `git show fa3492c5f7645feb979c767046b6ff335ea9d6ca`

```diff
-                    • filter (function|nil): Predicate to filter clients used
-                      for formatting. Receives the list of clients attached to
-                      bufnr as the argument and must return the list of
-                      clients on which to request formatting. Example:    • >
+                    • filter (function|nil): Predicate used to filter clients.
+                      Receives a client as argument and must return a boolean.
+                      Clients matching the predicate are included. Example:    • >

                         -- Never request typescript-language-server for formatting
                         vim.lsp.buf.format {
-                          filter = function(clients)
-                            return vim.tbl_filter(
-                              function(client) return client.name ~= "tsserver" end,
-                              clients
-                            )
-                          end
+                          filter = function(client) return client.name ~= "tsserver" end
```

The solution is right there in the documentation ❤️ and exactly the same as the snippet I had in my `init.lua` 🤯 (what are the chances)

I made the corresponding change in my Dotfiles [here](https://github.com/Jackevansevo/Dotfiles/commit/6d6166fd3e28761a52f44cd83098bcbc6e7cb7de) and everything works.

Takeaways:
- If you're using nightly builds: things are probably going to break (and that's okay)
- Don't be scared to browse commits and investigate for yourself, this is the power of open source!
- The Neovim documentation is great

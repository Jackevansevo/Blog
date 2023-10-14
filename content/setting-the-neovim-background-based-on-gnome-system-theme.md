Title: 🌓 Setting the Neovim background from the Gnome system theme
Date: 2023-01-29
Status: published
Tags: Linux, Neovim

I wanted to set my Neovim background conditionally based on the Gnome system
theme (light/dark).

I came up with the following snippet, which lives in my `init.lua`

```lua
local Job = require'plenary.job'

job = Job:new({
  command = 'gsettings',
  args = { 'get', 'org.gnome.desktop.interface', 'color-scheme' },
})


if job:sync()[1] == "'prefer-dark'" then
  vim.opt.background = 'dark'
else
  vim.opt.background = 'light'
end
```

The downside here is you have to re-source your `init.lua` after changing the
system theme, so the process isn't automatic. I wonder whether I'd be able to
run a background process to poll for this value (or subscribe to events) to
automatically change the theme.

I plan to play around getting this working on MacOS (which I use for work) as
well.

---

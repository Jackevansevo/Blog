Title: 🎨 Building colour schemes with mini.base16
Date: 2023-10-15
Status: published
tags: neovim

I'm a huge fan of [mini.nvim](https://github.com/echasnovski/mini.nvim). If you're unfamiliar here's a description from the plugins readme:

<div class="alert alert-info">
Library of 30+ independent Lua modules improving overall Neovim (version 0.7 and higher) experience with minimal effort. They all share same configuration approaches and general design principles.
<br>
<br>
Think about this project as "Swiss Army knife" among Neovim plugins: it has many different independent tools (modules) suitable for most common tasks. Each module can be used separately without any startup and usage overhead.
</div>

Out the box it replaces 90% of the plugins I was previously using. The major
benefit here is that the mini.nvim plugins are cohesive and designed to work
together. Consequently I've not encountered any behaviour with conflicting
plugins, i.e. overlapping keybindings, like I'd experienced in the past.

---

## mini.base16

mini.nvim comes with [a few
themes](https://github.com/echasnovski/mini.nvim#plugin-colorschemes)
`minischeme`, `minicyan` and `randomhue` (which you can see
[here](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-base16.md#demo))
but these aren't really to my taste.

Fortunately, mini.nvim comes with:
[mini.base16](https://github.com/echasnovski/mini.base16), a plugin that allows
you to generate vim colourschemes from a base16 palette. The [base16
project](https://github.com/chriskempson/base16) is a popular framework for
expressing colourschemes from a palette of 16 colours. Various tools exist to
convert these palettes into colourschemes for different applications.

<div class="alert alert-warning fst-italic">
Aside: if you've been programming for
any length of time, you'll probably immediately recognise some of the more
popular base16 palettes, as they're used by a <a class="alert-link fw-normal" href="https://github.com/chriskempson/base16#used-by">quite a few popular applications</a>
</div>

<br>

**What about existing base16 vim colourschemes?**

base16 already has existing colourscheme ports available in the form of
[chriskempson/base16-vim](https://github.com/chriskempson/base16-vim), various
lua ports also exist for neovim. These are great if you're happy with a fairly
vanilla vim/neovim setup.

The problem is these colourscheme implementations might not necessarily support
certain third plugins you're using, so things might end up looking ugly or
visually broken.

Using the [mini.base16](https://github.com/echasnovski/mini.base16) plugin you
can take a base16 colour palette and generate a neovim colourscheme that
supports all the mini.nvim plugins + a bunch of popular third party vim/neovim
plugins (a full list of supported plugins is available
[here](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-base16.md#features)).

The end result is something like this:

![base16 mocha mini.base16 theme]({static}/images/base16-mocha.png)


### Building Themes

Here's an example base16 palette (for the [mocha colourscheme](https://github.com/chriskempson/base16-default-schemes/blob/master/mocha.yaml)):

```yaml
scheme: "Mocha"
author: "Chris Kempson (http://chriskempson.com)"
base00: "3B3228"
base01: "534636"
base02: "645240"
base03: "7e705a"
base04: "b8afad"
base05: "d0c8c6"
base06: "e9e1dd"
base07: "f5eeeb"
base08: "cb6077"
base09: "d28b71"
base0A: "f4bc87"
base0B: "beb55b"
base0C: "7bbda4"
base0D: "8ab3b5"
base0E: "a89bb9"
base0F: "bb9584"
```

I can take these definitions and create a corresponding `mini.base16` colourscheme:

```lua
require('mini.base16').setup({
  palette = {
    base00 = "#3B3228",
    base01 = "#534636",
    base02 = "#645240",
    base03 = "#7e705a",
    base04 = "#b8afad",
    base05 = "#d0c8c6",
    base06 = "#e9e1dd",
    base07 = "#f5eeeb",
    base08 = "#cb6077",
    base09 = "#d28b71",
    base0A = "#f4bc87",
    base0B = "#beb55b",
    base0C = "#7bbda4",
    base0D = "#8ab3b5",
    base0E = "#a89bb9",
    base0F = "#bb9584",
  },
})

vim.g.colors_name = "base16-mocha"
```

I found it quite painful to manually have to copy/paste these values over from
a `.yaml` colour palette into the equivalent `.lua` format that `mini.base16`
expects. So I wrote a quick and dirty Python script to do the conversion:

```python
from pathlib import Path

for theme in Path('.').glob("*.yaml"):
    out = theme.with_suffix('.lua')
    lines = ["require('mini.base16').setup({", '  palette = {']
    for line in theme.read_text().splitlines():
        if line.startswith('base'):
            dec, color = line.split(': ')
            lines.append(f'    {dec} = {color[:1] + "#" + color[1:]},')
    lines.append('  },')
    lines.append('})\n')
    lines.append(f'vim.g.colors_name = "{theme.stem}"')
    out.write_text("\n".join(lines))
```

Or you can take the existing [vim base16 themes]() and convert these to the `mini.base16` lua equivalents

```python
from pathlib import Path

for theme in Path('colors').glob("*.vim"):
    out = theme.with_suffix('.lua')
    lines = ["require('mini.base16').setup({", '  palette = {']
    for line in theme.read_text().splitlines():
        if line.startswith('let s:gui'):
            _, dec, _, color = line.split()
            lines.append(f'    base{dec[5:]} = {color[:1] + "#" + color[1:]},')
    lines.append('  },')
    lines.append('})\n')
    lines.append(f'vim.g.colors_name = "{theme.stem}"')
    out.write_text("\n".join(lines))
```


## 🖼️ Theme showcase

Below is an example of a few mini.base16 themes in action:

<video class="w-100" controls>
    <source src="{static}/images/base16-themes.mp4">
</video>

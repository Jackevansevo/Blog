Title: Building colour schemes with mini.base16
Date: 2023-09-26
Status: draft

I'm a big fan of [mini.nvim](https://github.com/echasnovski/mini.nvim). Since
giving it a try it's replaced 90% of the plugins I used to use in vim and
replaced them with a cohesive ecosystem of plugins that work really well
together.

One of those plugins in
[mini.base16](https://github.com/echasnovski/mini.base16) which is a little
plugin that allows you to generate vim colourschemes from a base16 palette.

This means you can take a base16 colour palette like:


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


And use `mini.base16` to generate a corresponding vim colourscheme.

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

Here's a simple Python script to do the conversion:


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


Or you can take the existing vim base16 themes and convert these to the `mini.base16` lua equivalents

```vim
" GUI color definitions
let s:gui00        = "3B3228"
let g:base16_gui00 = "3B3228"
let s:gui01        = "534636"
let g:base16_gui01 = "534636"
let s:gui02        = "645240"
let g:base16_gui02 = "645240"
let s:gui03        = "7e705a"
let g:base16_gui03 = "7e705a"
let s:gui04        = "b8afad"
let g:base16_gui04 = "b8afad"
let s:gui05        = "d0c8c6"
let g:base16_gui05 = "d0c8c6"
let s:gui06        = "e9e1dd"
let g:base16_gui06 = "e9e1dd"
let s:gui07        = "f5eeeb"
let g:base16_gui07 = "f5eeeb"
let s:gui08        = "cb6077"
let g:base16_gui08 = "cb6077"
let s:gui09        = "d28b71"
let g:base16_gui09 = "d28b71"
let s:gui0A        = "f4bc87"
let g:base16_gui0A = "f4bc87"
let s:gui0B        = "beb55b"
let g:base16_gui0B = "beb55b"
let s:gui0C        = "7bbda4"
let g:base16_gui0C = "7bbda4"
let s:gui0D        = "8ab3b5"
let g:base16_gui0D = "8ab3b5"
let s:gui0E        = "a89bb9"
let g:base16_gui0E = "a89bb9"
let s:gui0F        = "bb9584"
let g:base16_gui0F = "bb9584"
```

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

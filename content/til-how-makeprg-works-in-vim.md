Title: TIL: Using makeprg to integrate pytest in Vim
Date: 2023-03-13
Status: published
Tags: Vim, Programming

# Current Sitution

Up until recently I had been running my tests with something like the following:

```
:vsplit | term pytest %
```

I typically use different keybindings to invoke pytest with different arguments
(such as -s to debug when setting breakpoints)

Here's a little demo:

<video class="w-100" controls>
<source src="{static}/images/Screencast from 2023-03-13 18-33-49 (trimmed).webm">
</video>


I liked this approach because it was simple and didn't require any additional
plugins, it simply takes advantage of Neovims built in [terminal
emulator](https://neovim.io/doc/user/nvim_terminal_emulator.html).

One of the benefits of this is that the terminal task is non blocking, so I can
continue editing code without long running tests blocking the UI.

However, a major downside of this approach is that is doesn't take advantage of
some of the more powerful builtin vim features.

Ideally, test failures would appear in the [quickfix
list](https://vimdoc.sourceforge.net/htmldoc/quickfix.html), making it possible
to quickly jump to the exact lines that failed within tests, right inside my
editor.

<br>

# Enter makeprg

I was inspired by [this youtube
video](https://www.youtube.com/watch?v=vB3NT9QIXo8) detailing the `makeprg` and
`compiler` features in vim, and decided to give this method a try (in favour of
my previous approach).

Because vim doesn't include a pytest compiler by default, I installed
a [plugin](https://github.com/tartansandal/vim-compiler-pytest) to provide this
functionality.

Under the hood this plugin is defining the error structure of pytests output.
With this information vim can parse the output from pytest and display
errors/filenames in the quickfix list.

Getting this all working is as straightforward as running:

```
compiler pytest
```

I can then invoke pytest with:

```
make %
```

(Percent is vim-speak for the current buffer filename)

Here's video a comparison:

<video controls>
<source src="{static}/images/Screencast from 2023-03-13 18-35-10 (trimmed).webm">
</video>

Invoking pytest via make populates the quickfix list with errors. This allows
me to quickly jump to error locations directly from within my editor.

<br>

# But wait, there's more

The major downside of the previous approach is that it blocks the UI, so I've
lost the asynchronous benefits of my original integrated terminal approach.

However, it's possible to get these tests to run asynchronously (aka: without
blocking the UI) by using:
[vim-dispatch](https://github.com/tpope/vim-dispatch).

This pops open a little tmux window I can quickly switch to with `C-b + o`

Here's the final result:

<video controls>
<source src="{static}/images/Screencast from 2023-03-13 18-41-54 (trimmed).webm">
</video>

<br>

# Conclusion

Overall I'm quite happy with the final result, and pleased I'm leveraged more
of the builtin features of vim to make my life easier.

If you'd like to learn more about these built-in vim features I recommend
reading:
[https://learnvim.irian.to/basics/compile](https://learnvim.irian.to/basics/compile)
which I found incredibly helpful.


<br>

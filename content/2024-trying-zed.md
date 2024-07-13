Title: Trying zed
Date: 2024-07-13
Status: published
Tags: neovim, vim, editors

I've been following the development of [Zed](https://zed.dev/) for a while. As
a pretty diehard vim user myself, my interest was peaked after reading [From
Vim to Zed](https://registerspill.thorstenball.com/p/from-vim-to-zed) by
[Thorsten Ball](https://substack.com/profile/1234646-thorsten-ball), which
documents the experience of a long time vim switching to Zed.

I also recently finished watching an interview with the founder (Nathan Sobo)
on the [Developer Voices Podcast](https://www.youtube.com/watch?v=fV4aPy1bmY0)

<div class="ratio ratio-21x9">
<iframe src="https://www.youtube.com/embed/fV4aPy1bmY0" title="Building the Zed Text Editor (with Nathan Sobo)" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
</div>

<br>

On a more personal note, I noticed the Zed team recently hired some super
talented developers that I respect/look up to (so it must be good right?).

So a couple of weeks ago I decided to ditch neovim completely and try out Zed,
using it for 100% of my day to day coding. After two weeks I thought I'd share
how my experience went.

---

## Things I liked

### Change of scenery

A little weird to start with, but I've been using a pretty similar vim setup
for a decade now, so trying something new was a nice change of scenery.

Kind of like switching to working from a coffee shop,co-working space, or
outdoor space after being holed up in your office for an extended period of
time

Was the code I wrote any better as a result? I doubt it. But was it refreshing
and exciting to be writing code in an environment that felt completely new.

### GUI Appearance

Whilst I do appreciate the aesthetic of my terminal neovim setup, it's
difficult to deny a well designed GUI editor simply looks better.

Instead of having to hack together splits, tabbars and statuslines with unicode
symbols and text UI elements in Zed just look way nicer.

Opening zed for the first time I feel like they've put a lot of effort into
making things look beautiful. I'm a bit fan of their default font and the
builtin colour schemes.

### Sensible Balance Between Built-Ins vs 3rd Party Plugins

It's my understanding Zed has only recently opened up it's core to allow
community members to start writing their own editor extensions. Instead of
relying on community plugins the creators seem to be aiming for a more curated
experience where core functionality is provided by the editor itself. To get an
idea about what's included, check out the [feature Just
checklist](https://zed.dev/features) on their site

Unlike neovim which is completely modular, Zed provides a lot of useful
features out of the box such as git integration, auto completion, auto pairs,
LSP support and tree sitter.

Vim/Neovim is pretty barebones in comparison, instead you have to reach for
third party plugins to provide useful functionality.

In my opinion this is both the ecosystems biggest strength, and its biggest
weakness. Although there's a healthy ecosystem of plugins to choose from, it's
easy to feel a sense of decision paralysis when deciding which combination of
plugins to use.

I love to tweak and tinker with my neovim configuration as much as anyone, but
lately I'm seeing more value in using a setup that's curated from the ground
up. Things are just guaranteed to work together in a way that a myriad of third
party plugins can't.

I think it's a positive thing that text-editors like Zed (and helix)
acknowledge the utility of certain functionality and provide these features out
of the box. I think over time I'd like to see neovim do the same, (why aren't
['nvim-treesitter/nvim-treesitter'](https://github.com/nvim-treesitter/nvim-treesitter)
and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)) just part of
core neovim already?

This meant I was able to fire up Zed and actually start being productive with
essentially zero tweaks to my config. I chose a colour scheme I liked, enabled
Vim mode and suddenly I was writing code.

### Comprehensive vim mode

Coming from neovim it's a non-starter for me if an editor doesn't support modal
editing or provide vim key mappings. A lot of editors kind of get the basics
right, but there's weird corners where things ends up not working as you'd
expect. Unless you're a vim user this kind of uncanny valley behaviour is
difficult to explain.

Thankfully in Zed the vim mode feels really well thought out, it complements
the editor experience and usually does what you'd expect it to.

There's a really interesting discussion on zed's vim-mode and why they chose to
not 'just embed neovim' and instead do their own things (spoiler they have
different goals).

### Performance

The editor feels super snappy, responsive and fairly light on resources. One of
the things that prevents me from ever using VSCode for any length of time is
that the experience feels sluggish, especially on older hardware.

At no point during my trial did the editor freeze or or feel laggy, everything
felt pretty buttery smooth.

### Click to open files

Something super simple (but something completely missing from my terminal
workflow) is the ability to click to open a file in the terminal output and
have this pop up in the editor.

This is great when running tests or linters and just directly jumping to the
location in your editor to fix the problem.

In neovim I'm accustomed to highlighting the path to a file in a terminal tab,
switching back to my neovim tab and then opening with `:e <filename>`, which in
comparison is super inconvenient.

Now I've gotten used to the way Zed handles this it will be frustrating to ever
revert back.

### Multi cursors

There's a group of people in the vim community that are adamant multi-cursors
ren't something that's needed. Technically you **can** do anything achievable
with multi-cursors, but IMO that doesn't mean you **should** settle for it.

Zed manages to implement this feature in a way that feels like it complements
vim and feels much more useable that whatever the vim alternative would be.


### Built in terminal

When I decided I give Zed a try I told myself I'd go all in, abandoning
a designated terminal app completely. So when running tests, scripts and
services I've been doing using Zeds builtin terminal.

I like being able to quickly access the builtin terminal with Command+J, having
a keybinding on the home-row makes it easy to access. Likewise being able to
toggle full-screen this window with Shift+Escape means I was able to completely
replicate what I was doing inside Iterm beforehand.

---

## Things I Disliked

### Buffer/Split Management

My brain has been altered by the way vim/neovim manages splits and buffers.
Fundamentally this makes it difficult for me to adapt to a tab based workflow.
In vim a split is just a window into underlying buffers. Splits share the same
underlying buffers, meaning you can cycle between all open buffers in any
split.

In zed (and most other GUI editors) if you make a separate window split, you
can only cycle through tabs that belong to that split. Frequently, I found
myself making new splits and having to do some manually tab management to get
what I wanted.

Furthermore, one of the settings I have in enabled in neovim is
splitright/splitbelow. This means when I create a new split it automatically
focusses the new split to the right (or below) of my existing window. In zed
the opposite happens, which I found quite jarring.

### LSP Support

I'm used to running both ruff and pylsp at the same time, the former helps lint
& format my code whereas the latter does more typical language server things
like provide jump to definition and variable renaming.

Currently it's only possible to use Python with the default `pyright` language
server https://zed.dev/docs/languages/python

This really is one of major things preventing me from making the leap to Zed
completely. I really hope in the future they open up the editor to support any
LSP's (not just the default recommended one), and allow multiple of them to run
at the same time.

# Conclusion

Overall my experience was positive and I'm excited to see how the editor
evolves/improves other time. If you're curious, I'd encourage you to give it
a try yourself.

In the modern era of boated election apps and excessive RAM usage it's awesome
to see the original authors of Atom (and it's electron framework cousin) take
another stab at building an editor but this time with a focus on performance.

I think once the LSP support is more mature I'll definitely be giving it
another go!


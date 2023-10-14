Title: Revisiting KDE
Date: 2023-01-15
Status: published
Tags: Linux

# Background

It's been years since I last used the KDE desktop environment. Unfortunately, I
don't have an exact screenshot of my desktop when I last used KDE, but from
memory it probably looked a lot like this:

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/KDE_4.png/1024px-KDE_4.png" alt="KDE Oxygen desktop"/>

Looking back I'm not sure the Oxygen theme has aged particularly well, but this
picture fills me with nostalgia and so will always have a special place in my
heart.

Over the years KDE has (unfairly in my eyes) had a fairly negative reputation,
and stereotyped for being quite buggy and resource hungry. I don't recall being
affected by these issues described first hand, but hearing critical sentiments
like this left me with a negative impression and drove me away from using KDE.
So although I do have fond memories of this desktop, they were tainted by the
opinions of a few vocal Linux enthusiasts at the time. I was young and
impressionable, and wanted to use to use the 'best' thing, even if that meant
not being able to form my own independent assessment.

Consequently I was content to stay on Gnome desktop (and various forks) for most
of my time on Linux. But that all changed pretty recently. I wanted to revisit
KDE and see if this reputation was still warranted. I think part of me wanted to
make amends and give some love to a Desktop environment I felt I'd never really
given an honest chance.

Largely I was inspired to give KDE another try after seeing some pretty positive
recent momentum in the community. A prime example is TechHut releasing this
video:

<div class="ratio ratio-21x9">
<iframe
src="https://www.youtube.com/embed/3nX1YEQg5Z0" title="10 ways KDE is just
BETTER" frameborder="0" allow="accelerometer; autoplay; clipboard-write;
encrypted-media; gyroscope; picture-in-picture; web-share"
allowfullscreen></iframe>
</div>

<br>

I follow Nate Graham on his blog ["Adventures in Linux and
KDE"](https://pointieststick.com) who's posts frequently hit the front-page of
[/r/linux](https://reddit.com/r/linux), which makes developments in KDE
impossible to ignore. It's really impressive to see the volume of improvements
that go into the desktop each week.

All of this positive sustained coverage culminated in me caving and deciding to
see what all the fuss was about.

I opted to install Open SUSE Tumbleweed because I fancied trying out a rolling
release distribution and wanted an up-to-date KDE experience without having to
jump through hoops. I briefly toyed with the idea of trying KDE Neon, but
ultimately wanted something different then another Ubuntu based distribution.

> Disclaimer At the time of writing I'm on KDE Plasma version 5.26.5.

---

# The Good

## Applets

I always found the applets on Gnome to be a bit frustrating, and find much great
utility from their KDE counterparts. Frequently on Gnome I'd be forced to open
up system settings to perform some basic action, like switching/connecting a
Bluetooth device or altering specific device volume.

<img src="https://pointieststick.files.wordpress.com/2023/01/kscreen-applet-in-system-tray.jpg?w=650&h=172" alt="KDE applets"/>

Whereas on KDE applets typically quickly allow me to to perform the required
action without having to dive into the full settings. On Gnome there's a
patchwork of [3rd party
extensions](https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/
) that [fill this niche](https://www.omgubuntu.co.uk/2022/09/bluetooth-quick-connect-gnome-extension) but I find myself much preferring the out of the box
experience offered by KDE.

<img src="{static}/images/kde-bluetooth-applet.png" alt="KDE Bluetooth applet"/>

## Multi Monitor Support

To my surprise everything just works, I haven't had a single issue with
multi-monitor support so far. All this is even before some [multi-screen
improvements](https://notmart.org/blog/2022/12/multi-screen/) due to arrive in
Plasma
5.27

Often I'll plug my laptop in to drive a primary display but then close the lip
on my laptop, running just one display. When I do this all the windows open on
my laptop automatically switch over to the main display.

The Display Configuration Applet makes it really easily to quickly kill the
laptop screen and work from the Primary monitor even when the laptop lid is
open. Traditionally multi-monitor configuration on Linux has been a nightmare, but
this has been working a charm for me.

## KWin Customisation (Disabling Borders Per Application)

A small thing that might be possible in other environments, but KDE makes super
trivial. I'll often configure this when I have two windows side by side. This
sort of mirrors the way I used to use the i3 tiling window manager, allowing me
to arrange borderless windwos for maximum vertical space.

![KWin hide boders]({static}/images/kde-hide-borders.png)

## Theming

I quickly switched from the default openSUSE theme to default Breeze
implementation. I'm a big fan, everything ends up looking nice and consistent
across the desktop. The ability to inherit the accent colour from the current
wallpaper is a nice touch. Although I do wish there was a nice way to
automatically to switch from Light/Dark mode based on the current locale
(similar to the way android works).

![Breeze Theme Switcher]({static}/images/breeze-themes.png)

## KDE Apps

### Kate

It's been a while since I tried out this editor and I'm pleased to see it's
developed a bunch of useful new features since. Now it's got builtin LSP
support, git integration, session support and a quick 'Quick Open Search' fuzzy
file searcher. What more could you need from a modern lightweight editor
(without reaching for a full IDE).

The comprehensive vi input mode, combined with the rest of the editor experience
means it's so good that I'll stray from my typical neovim terminal setup (which
is high praise). It would be absolutely fantastic if at some point neovim gets a
proper headless mode to allow it to be easily integrated with GUI-editors. If
Kate, (or similar) ever developed this feature I'd love to use the editor as a
front-end UI for neovim. But I'm unsure whether this is within the scope of the
project.

I've had a few issues configuring the LSP integration from within a Python
virtual-environment, but aside from this the experience has been very positive.

<img src="{static}/images/kate.png" alt="Kate editor"/>

## Stability

This one is surprising to me and I'm on Open SUSE tumbleweed, which pulls
up-to-date versions of software from upstream repositories. I expected lots of
crashes, everything to be bug-ridden, constantly encountering little regressions
with each update. I'm pleased to say this hasn't been the case, I've only had a
single crash (albeit a pretty serious one) so far which I'll touch on in the
next section.

# The Not So Good

Most of my experience has been pleasant, but I did encounter a few minor issues,
which I've documented below.

## *Krashes*

When I came to wake my laptop from sleep I was greeted by the following (fairly
intimidating) error message screen. Instead of following the instructions on
screen I just hard rebooted my machine 🥱.

<img src="{static}/images/PXL_20230105_192004711.jpg" alt="Kate editor"/>

## Application Task Switchers (Alt+Tab Switcher) Styles

My most recently used desktop environments before trying KDE have been MacOSX,
Gnome and Cinnamon. A common trait they share is that each have a pretty similar
Alt+Tab look and feel, a style I appreciate.

KDE has a variety of application launchers to choose from, but in my opinion
none of them look quite as visually appealing. With the Large Icons the spacing
sometimes looks off, and app icons will occasionally look blurry or missing
completely, on the other hand the Small Icons switcher is simply way too small.
I've settled on using the default Breeze switcher, which I initially had an
aversion to due to it's placement on the left hand side of the screen.

<img src="{static}/images/kde-icon-task-switcher.png" alt="KDE Task Switcher"/>

I think this is partially my fault for using Flatpak applications and expecting
the desktop integration be 100% seamless. I strongly suspect it might also be an
upstream issue (and not the fault of KDE itself), but I've not encountered
similar issues on Gnome/Cinnamon.

## App Launcher Search Relevancy

### Krunner vs Application Launcher vs Overview

The functionality offered by all of these launchers appears to completely
overlap. So I'm not sure when I'd opt to use one over the other? This is
obviously just a skill issue, but I think I prefer the unified search
implementation offered by Gnome shell which removes any ambiguity.

### Search Relevancy

Occasionally I'll search for something and what I'm looking for will be the
second most relevant result, which can be frustrating.

**Example A:** If I type word *"mouse"* to bring up the settings panel to configure my
mouse, the first two characters "mo" returns a list of results where Htop is the
most relevant.

![KDE Mouse Search]({static}/images/kde-search-mouse.png)

**Example B:** If I type *"settings"* the top result is Steam settings. In 99% of
cases, this is never the result I want. I feel like KDE built-ins should take
precedence here. Or perhaps there should be reserve words that prevent
third-party applications from appearing as the top result.

![KDE Settings Search]({static}/images/kde-search-settings.png)

**Example C:** If I type *"Downloads"* I get x3 results. If I want to open my
~/Downloads folder in Dolphin which one is correct?

In this scenario the first result opens up a KDE Settings Panel to change the
default Download location (unlikely what I want). The second two results are
equivalent, likely from two search plugins returning the same thing.

![KDE Downloads Search]({static}/images/kde-search-downloads.png)

All very minor things, but it frequently makes me double take before I hit the
<enter\> when searching, which can be annoying.

I disabled a majority of the enabled search plugins very early on to try and
improve the experience, speed up the search and provide more relevant
results. But I still run into occasional issues like this.

There's a good chance that my muscle memory from other desktops is tainting my
experience on KDE. But I do think both the Gnome and Cinnamon desktops to a
better job of this out of the box. On Cinnamon I would blindly hit <super\>
start typing then slam <enter\> without thinking and it would somehow always do
the right thing.

# Conclusion

Overall my experience so far with KDE has been overwhelmingly positive, despite
some of the criticism covered in this article. It's great to see how far the
desktop has improved since I last used it, and I'm excited to see where the
project goes in the future, especially with KDE 6 on the horizon.

I plan to stick with KDE for the foreseeable future, or until I get the nagging
urge to jump ship and try something new :P

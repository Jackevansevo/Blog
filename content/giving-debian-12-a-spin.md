Title: Giving Debian 12 'Bookworm' a Spin
Date: 2023-06-15
Status: published
Tags: Linux, Debian

Debian 12 'Bookworm' was recently released, and a number of different factors
aligned that made me decide to give it a go.

<div class="ratio ratio-21x9">
<iframe src="https://www.youtube.com/embed/pwx-TujW8sE" title="Debian 12
&quot;Bookworm&quot; is the Best Release of Debian. Ever." frameborder="0"
allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope;
picture-in-picture; web-share" allowfullscreen></iframe>
</div>

## Switching

It's been a number of years since I daily drove a Debian, but it's a distro that
I've always had a soft spot for. Back at university I interned at a company
where a number of employees were contributors to the Debian project, which at
the time I was enamoured by. I respected their Linux expertise and no-nonsense
approach to system administration, something I feel is reflected in the Debian
culture.

<img src="{static}/images/Screenshot_20230615_222129.png" alt="Debian
desktop"  style="max-height: 600px"/>

The distribution itself has a reputation for rock solid stability, historically
not great for users that want the latest and greatest features, but ideal for
being predictable, staying out your way and allowing you to get work done.

I've always had the sense that if I really wanted a reliable, non-thrills
desktop that I was confident would work for years to come I'd definitely
consider either Debian for personal use. Perhaps if I was installing something
for a family member I'd consider something like Linux Mint. But for myself, I'm
easily distracted and chronically addicted to new shiny things so rarely stick
with one distribution for extended periods of time.

## Saying Farewell to Open SUSE 🦎

I was previously using KDE plasma desktop on Open SUSE, a rolling release distro
that includes all the latest and greatest packages. With the latest release of
Debian 12 the stars aligned perfectly it includes the latest (at the time of
writing) KDE Plasma version 5.27.5, identical to what I was using on SUSE. This
also represents the [latest major release of KDE plasma version
5](https://community.kde.org/Schedules/Plasma_5#LTS_releases) before KDE plasma
6.

Below is a quote taken directly from the [KDE Plasma 5
schedule](https://community.kde.org/Schedules/Plasma_5#LTS_releases)

> The current LTS release is Plasma 5.27.

> This is the last Plasma 5 release and will receive bugfixes only, no new features. The bugfixes are intended to continue being integrated into 5.27 until a first version of Plasma 6 can be released (and might continue longer).

I'm hoping this means I'll continue to get the KDE experience I've grown
accustomed to for the foreseeable future without having to worry about potential
breakage of unstability introduced by KDE Plamsa 6 (Something I'd potentially
more likely to encounter sticking with Open SUSE)

For the most part my experience using Open SUSE was positive. I was pleasantly
surprised by the stability of a rolling release desktop. However I occasionally
ran into issues with conflicting packages, with no clue how my system managed to
end up in such a state and unsure what actions to take to resolve said
conflicts.

Furthermore, using Open SUSE was a departure from what I'm more familiar with.
Historically I've mostly used Debian or Ubuntu based distrubtions, as such I'm
much more confortable using apt compared to tools like zypper or yast.

## Impressions

I think it's a huge improvement that Debian is including non-free firmware
(where required) in the official installation media. I remember the days where
Wi-Fi on my old thinkpad didn't work post-installation until I'd enabled some
non-free sources. This kind of stuff is just user hostile (especially for
beginners) and I feel this will really help adoption.

<img src="{static}/images/Screenshot_20230615_221037.png" alt="Debian about
this system dialogue"  style="max-height: 600px"/>

In terms of the desktop experience I really appreciate that Debian provides a
very vanilla experience out of the box. Similar to the approach I've seen Fedora
take, there's no major attempts customize any of the desktop environments they
ship.

Enabling flathub and install packages from flathub means my setup now feels 100%
identical on the surface, the only difference being the underpinnings of the
distribution. I think this speaks to one of the main advantages of Debian in the
current ecosystem. When combined with flatpak you get the best of both worlds: a
rock solid distrbution base and (potentially) the latest and greatest versions of
popular applications via flathub.

## Issues

The only one issue I had was getting video capture working with pipewire in OBS
Studio. After trying both the .deb version and flatpak I was unable to add my
desktop as a screen capture source, resulting in the following warning in the
logs:

```
warning: [pipewire] Failed to start screencast, denied or cancelled by user
 ```

After a lot of googling it turns out I just needed to install an extra
'metapackage' pipewire-audio
[https://wiki.debian.org/PipeWire#Installation](https://wiki.debian.org/
PipeWire#Installation) which I guess it not included by default when using KDE
plasma.

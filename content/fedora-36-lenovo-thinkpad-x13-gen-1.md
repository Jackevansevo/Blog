Title: Review Fedora 36 on the Lenovo Thinkpad X13 (Gen 1) 🐧💻
Date: 2022-08-07
Status: published
Tags: Linux, Fedora

![Thinkpad X13]({static}/images/thinkpad-x13.jpg "Writing this post with a morning Coffee")

I recently picked up a used Lenovo Thinkpad X13 from eBay with the intention of
replacing my well loved Thinkpad X220 which is starting to show its age.

After a brief stint attempting to exclusively use WSL, frustrations with high
memory usage and intrusive Windows updates led me to try dual booting Fedora.
Overall it's been a positive experience and something I wish I'd done sooner.

This is just a quick run down of my experience with Fedora on the Thinkpad X13.
This isn't intended to be a review of the hardware, merely a first hand account
of how the distro performs/interacts when installed on the device.

![Thinkpad X13]({static}/images/thinkpad-x13-top-down.jpg "Top down view (ignore the fingerprints)")


# Upsides

A quick rundown of things that have historically plagued Linux in the past, and how this distro compares:

- ✅ WiFi: works out of the box
- ✅ Suspend resume appears to work
- ✅ Closing the lid appears to suspend / hibernate the laptop
- ✅ Function keys: all work
- ✅ Fingerprint reader: works out of the box (which surprised me)
- ✅ External HMDI monitor works when plugged in via USB-C hub


## Gnome Desktop

It's nice to see the Gnome Desktop continues to improve:

- I much prefer the new default horizontal workspace management on Gnome desktop
  - Coming from MacOS / Windows (or even alternate Linux desktop) this feels much more intuitive.
- I'm a fan of the new GK4 Libadwaita theming, everything feels nice and consistent (providing you don't install an application outside of the Gnome ecosystem)
- System performance feels really snappy, with low idle memory usage
![Resource Usage]({static}/images/gnome-system-monitor.png "Resource usage with typical Django docker compose web-dev workflow")

- I like the new system wide dark/light theme preference
  - But I wish that similar to MacOS this could be toggle automatically during the day/night cycle (similar to the way night light works)
- I haven't had a single desktop crash (so far)
- I appreciate the new Gnome power mode settings, which lets me throttle performance to save power when away from my desk

![Gnome power saver]({static}/images/gnome-power-saver.png)


# Downsides

- The builtin Gnome desktop screen/video recorder seemed to record choppy/laggy video
  - Would have been nice if this had worked smoothly out of the box but I was forced to revert to using OBS
- Firefox struggles with video playback out of the box (perhaps media codecs are required)
- Font rendering feels a bit lackluster on Fedora compared to the default MacOS or even Ubuntu experience
- It's impossible to right click using the touchpad

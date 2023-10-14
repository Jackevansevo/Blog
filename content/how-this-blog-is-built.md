Title: How this blog is built
Date: 2023-03-04
Status: draft
Tags: Programming

After a number of years trying, evaluating and abandoning a bunch of different
software, I've finally settled on the following set of tools to host & publish
content here.

# [Github Pages](https://pages.github.com/)

This is an obvious choice for a number of reasons. Github pages lets you host
static content completely free of charge. This is great because I don't have to
worry about maintaining my own infrastructure, nor do I have to worry about any
additional traffic or billing.

Github pages even supports [custom
domains](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-
github-pages-site/about-custom-domains-and-github-pages), should you want to
continue using your own.

<br>

# [Pelican](https://github.com/getpelican/pelican)

I've sank more time than I want to admit trying different static site
generators. I've even experimented with building my own, inspired by [this
tutorial](https://blog.thea.codes/a-small-static-site-generator/) by
[thea.codes](https://thea.codes/) which I highly recommend.

For a while I used [hugo](https://gohugo.io/), for most people this is probably
the best option. But personally, I found configuration a little difficult. Day
to day I write Python, so I feel way more at home editing Python code and Jinja
templates than I did when I was configuring my Hugo static site.

I really appreciate the separation of configuration files for development /
production, (i.e. pelicanconf.py vs publishconf.py). I found the default
templates to be readable and simple to extend, which made customizing the site a
breeze.

<br>

# [Vanilla CSS](https://vanillacss.com/)

I'm terrible at CSS so wanted something lightweight I could drop in and make
things look pretty automatically. Vanilla CSS Created by [Brad
Taunt](https://bt.ht) works perfectly for this.

I appreciate the fact that it supports [dark
mode](https://git.sr.ht/~bt/vanilla-css/tree/master/item/vanilla.css#L159). So
my site respects the users configured
[`prefers-color-scheme`](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme)
without any intervention on my behalf.

<br>

# Analytics

Analytics give me a great overview of **who** is reading my content, and
**how** they're finding it. With analytics, I know that typically my site only
get a trickle of traffic, mostly from people organically discovering content
via search engines.

But occasionally certain posts will get spikes of traffic, usually this happens
when posts are linked on a content aggregation site. When this happens, it's
really cool to see A) where the traffic is being directed from and B) where in
the world people are reading my content.

I'm by no means a 'analytics guy', I don't use the insights from analytics to
inform any kind of intelligent decisions, it's purely fun to observe what kind
of traffic my blog gets. For this reason, my personal requirements for a
analytics tool are pretty basic, and likely very different from someone who
deeply understands this space.

Initially I used Google Analytics, mostly out of sheer convenience because of
how quick and easy it was to setup. However, I soon learnt Google Analytics
[has](https://plausible.io/blog/google-analytics-adblockers-missing-data)
a [number](https://casparwre.de/blog/stop-using-google-analytics/) of
[problems](https://hn.algolia.com/?q=Google+analytics), not to mention it's
[potentially illegal](https://www.isgoogleanalyticsillegal.com/) in a number of
countries, given this, I decided to scope out some alternatives.

For a while I used the 30 day free trail of [Plausible
Analytics](https://plausible.io/sites), which bills itself as a lightweight
privacy conscious alternative to Google Analytics.

Although Plausible itself has a self hosted option, as my free trial came to an
end I decided to evaluate some other  analytics options.

After seeing a post by [Eli
Bendersky](https://eli.thegreenplace.net/pages/about) on [lobste.rs](lobste.rs)
titled [Using GoatCounter for blog
analytics](https://eli.thegreenplace.net/2023/using-goatcounter-for-blog-
analytics/) I really liked it and decided to give it a go

It didn't take long to figure out how to deploy and self host my own instance on
[fly.io](fly.io).

![Goatcounter]({static}/images/goatcounter.png)

I imagine I'll probably revisit self hosting both
[goatcounter]goatcounter(https://www.goatcounter.com/) and
[plausible](https://plausible.io/sites) analytics in the future, but for the
time being [counter.dev](https://counter.dev) provides what I need.

<br>

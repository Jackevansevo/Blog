Title: The struggles of building a Feed Reader
Date: 2022-10-05
Status: published
Tags: Python, RSS

<img src="https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Feed-icon.svg/1200px-Feed-icon.svg.png" style="width:18%;">

I recently I fell down the rabbit hole of building a
[feedreader](https://github.com/Jackevansevo/feedreader). At the time I was
unsatisfied with the free tier offering of tools like inoreader and feedly, so
naturally I figured I'd try and build my own, after all, how hard could it be?

**Aside:** This was well before discovering [miniflux](https://miniflux.app/),
which is a fantastic piece of software. I've since decommissioned [my own
attempt](https://github.com/Jackevansevo/feedreader) and now happily self host
my own miniflux instance instead.

---

Here's a non exhaustive list of issues I've encountered along the way.

## 1. Atom vs RSS

I'll start with perhaps the most obvious...

There's multiple different competing standards to subscribe to represent web
feeds. Each with it's own specification, quirks and features.

Thankfully there's a sufficient amount of overlap between specifications that
it's possible to store data in a consistent normalised format. However doing so
isn't always straightforward.

One of the first challenges I faced when ingesting data from different formats
was designing a consistent normalised representation. I wanted a single `feed`
table to handle data from both atom/rss feeds.

Here's a comparison table I grabbed from the Wikipedia page for [RSS compared
with Atom](https://en.wikipedia.org/wiki/RSS#RSS_compared_with_Atom) which
lists all the equivalent elements.

<table class="table table-striped table-hover table-sm">
<thead>
<tr>
<th>RSS 2.0</th>
<th>Atom 1.0</th>
</tr>
</thead>
<tbody>
<tr>
<td>author</td>
<td>author*</td>
</tr>
<tr>
<td>category</td>
<td>category</td>
</tr>
<tr>
<td>channel</td>
<td>feed</td>
</tr>
<tr>
<td>copyright</td>
<td>rights</td>
</tr>
<tr>
<td>—</td>
<td>subtitle</td>
</tr>
<tr>
<td>description*</td>
<td>summary and/or content</td>
</tr>
<tr>
<td>generator</td>
<td>generator</td>
</tr>
<tr>
<td>guid</td>
<td>id*</td>
</tr>
<tr>
<td>image</td>
<td>logo</td>
</tr>
<tr>
<td>item</td>
<td>entry</td>
</tr>
<tr>
<td>lastBuildDate (in channel)</td>
<td>updated*</td>
</tr>
<tr>
<td>link*</td>
<td>link*</td>
</tr>
<tr>
<td>managingEditor</td>
<td>author or contributor</td>
</tr>
<tr>
<td>pubDate</td>
<td>published (subelement of entry)</td>
</tr>
<tr>
<td>title*</td>
<td>title*</td>
</tr>
<tr>
<td>ttl</td>
<td>—</td>
</tr>
</tbody>
</table>

An RSS feed has a `description` whereas an Atom feed has a `subtitle`. If
you wanted to store this information as a generic 'feed' representation what
would you name this column?

In this instance the choice of name for the internal representation doesn't
particularly matter as both fields are equivalent.

But what about fields that are available in one specification that aren't
available in another? Where would you store this data?

If you're lucky, your language of choice might have some decent open source
libraries to parse these feeds and return a abstract/normalised 'feed' for you.
If not: writing a parser for these from scratch can be a bit tedious.

I started off using a great library called
[feedparser](https://pypi.org/project/feedparser/), which I found to be super
simple and robust (shoutout to the maintainers 👏). This which was excellent
for building a prototype, but further along in development I decided to
experiment with writing my own from scratch.

I was quickly able to parse a bulk of feeds that I subscribe to, but ran into a
few edge cases which required defensive code. The parser itself is still very
brittle. This gave me a real appreciation for libraries like feedparser and all
the corner cases they're able to handle.

## 2. Finding Feed Links (Inconsistent conventions)

Lets say I come across a site `example.com` which I'd like to subscribe to via
RSS/Atom. How do I find the feed URL?

Typically I'll try and look for an RSS link/icon on the page itself and copy
this value and paste into my feed reader of choice. Or I'll inspect the page
source and hunt down the link by CTRL+F searching for different patterns.

![RSS Inspecting Page Source]({static}/images/rss-inspect-element.png "Viewing the page source to find RSS links")

So far I've come across the following common patterns:

- `example.com/rss.xml`
- `example.com/index.xml`
- `example.com/feed.xml`
- `example.com/atom.xml`
- `example.com/feed`
- `example.com/rss`


### The problem with automating this approach

In an ideal world I'd like users to be able to just subscribe to `example.com`
without having to manually find this link. How would you go about doing this?

There's a few steps I can think of

#### Strategy 1.

You could scrape `example.com` and search for something like:


```html
<link rel="alternate" type="application/rss+xml" title="Example" href="/rss.xml">
```

Not all sites include a link to the RSS feed in the site `meta` (Occasionally
you have to parse the HTML body).

#### Strategy 2.

If this fails you could naively fall back to scraping common patterns, i.e:
`/rss.xml | /index.xml`  to see if any of these pages exist and then parse the
first result.

#### Strategy 3.

Or you could not bother at all and leave it up to the end user to be explicit
about what feed they wish to subscribe to.


## 3. Finding Entry Links

Some Atom feed links might contain `<link rel="alternate" type="text/html">`
indicating this is very likely the link to the underlying item/entry (not some
other external link).

```xml
<entry>
<title>2021-03-28</title>
<link rel="alternate" type="text/html" href="https://www.suckless.org/#2021-03-28"/>
<id>https://www.suckless.org/#2021-03-28T00:00Z</id>
<updated>2021-03-28T00:00Z</updated>
<published>2021-03-28T00:00Z</published>
<content type="html">
<p>On Wednesday, 2021-03-31 there will be scheduled maintenance of the suckless servers. It's estimated this will take about 2-3 hours from about 19:00 to 21:00 - 22:00 UTC+02:00.</p> <p>The mailinglist, website and source-code repositories will have some downtime.</p> <p><strong>Update:</strong> the maintenance was finished at 2021-03-31 19:10 UTC+02:00. Please let us know if there are issues.</p>
</content>
</entry>
```

Some Atom feeds just contain a `<link href="">`

```xml
<entry>
  <title>
    Finding performance problems: profiling or logging?
  </title>
  <link href="https://pythonspeed.com/articles/logging-vs-profiling/"/>
  <updated>2022-08-09T00:00:00+00:00</updated>
  <id>
    https://pythonspeed.com/articles/logging-vs-profiling
  </id>
</entry>
```

Some feed might contain a combination of both!

All this can make it tricky when finding the 'right' link for a particular
entry/item.

For example here's some (pretty naive) parsing logic I have in my Atom parser to
find the 'best' link for each entry:

```python
def link(self):
    links = self.et.findall("link", namespaces=self.nsmap)

    for link in links:
        # Return the best matching link
        if link.get("rel") == "alternate" and link.get("type") == "text/html":
            return link.get("href")

    for link in links:
        if link.get("rel") == "alternate":
            return link.get("href")

    for link in links:
        if link.get("rel") == "self" or link.get("rel") == "hub":
            continue

        href = link.get("href")
        if href is not None:
            return href
        else:
            return link.text

```

## 4. Published vs Updated

An entry might have `updated` but not published. If you weren't lucky enough to
scrape/fetch the feed when the entry contained `published` you'll never know.

```xml
<entry>
  <title>
    Blah Blah Blah
  </title>
  <link href="https://example.com/articles/example/"/>
  <updated>2022-08-09T00:00:00+00:00</updated>
  <content type="html" xml:base="https://example.com/articles/example/">
    Blah Blah Blah
  </content>
</entry>
```

In my feedreader backend I had to include the following default behaviour:

```python
if published is None and updated is not None:
    # Just for sorting
    published = updated
```


## 5. Description vs Content

The description field is intended to be a little snippet/preview of the article/entry itself.

Then the bulk of the article should end up in `content` itself.

Of course in practice that's not how it works.

Some feeds store the entire article body in `description` and don't have an empty `content`

Some feeds completely duplicate the article content across both `description` and `content`

I attempt to handle these scenarios with something like:

```python
if content is None and summary is not None:
    content = summary
    summary = None
elif summary == content:
    summary = None
```

Some feeds have an empty `description` and only serve `content`. To resolve
this this I opt to show a preview of the article content in place of the
missing description.

```jinja
{% if entry.summary %}
  {{ entry.summary|truncatewords:50 }}
{% elif entry.content %}
  {{ entry.content|truncatewords:50 }}
{% endif %}
```

Sometimes the entry can just be completely devoid of any information, I've encountered feeds like:

```xml
<entry>
  <title/>
  <id/>
  <updated>0001-01-01T00:00:00Z</updated>
  <content/>
</entry>
```

Some feeds only serve up the `description` and have a blank `content`, forcing
users to link through to read the article on the original site (semi defeating
the point of subscribing via  feedreader)

If you're writing any parser that attempts to ingest feed data you'll need
robust and resilient parsing logic to handle all these different edge cases or
recover from failures when you hit an unknown problem.

## 6. Datetime fields not timezone aware

Many feeds include timestamps that don't include any timezone information. It's
still unclear to me how to best handle this case.

In practice this might lead to bogus `published` or `updated` values because
the author is in a different timezone to you.

I.e. what happens if the Author is in a future timezone and they publish a post 5 hours ahead?

I opted not showing posts with published dates in the future, but this feels
like a compromise.

## 7. DB Size Constraints

Because the RSS and Atom feeds are pretty loose specs, they don't (to my
knowledge) impose any size constraints on field contents.

This can be an issue if you're hosting a service on the world wide web that let
users enter data. This arbitrarity means you're going to have to make some of
these decisions yourself (for me some of these decisions were wrong).

If you're planning on scraping feeds/entries and saving the contents to your
database there're some key things to consider:
- What's the max length a feed/entry title/subtitle?
- How much content are you willing to store?
- What happens when you encounter a field bigger than the max size?

Early on I added constraints to my DB layer thinking I had sensible limits that
would never be exceeded. But frequently ran into exceptions for perfectly valid
feeds forcing me to re-evaluate and bump max limit

At some point however there might be a cut-off after which you want to reject
content beyond a certain size threshold.

## 8. Attempting to slugify resources

I wanted nice links internal to my site, i.e. if you subscribed to:

https://overreacted.io/rss.xml

Which has a Feed title of `Dan Abramov's Overreacted Blog RSS Feed`

I wanted the URL for this feed to be:

- `/feed/dan-abramovs-overreacted-blog-rss-feed/`

This turned out to be a bit of a mistake because not every feed title is
guaranteed to be something you can slugify.

As an example I came across http://benyu.org/feed

Which has the title: `<title>-… — —</title>`

Good lucky trying to slugify that 🤦

### Better Solution

Feedly, inoreader and miniflux wisely completely sidestep this problem by instead just URL encoding the feed URL, i.e.

https://feedly.com/i/subscription/feed%2Fhttps%3A%2F%2Foverreacted.io%2Frss.xml

https://www.inoreader.com/feed/https%3A%2F%2Foverreacted.io%2Frss.xml

In hindsight I should have done the same.

## 9. Relative vs Absolute Links

Most feeds are pretty good about this, but every so often I run into:

Links to items/entries being relative:

```xml
<item>
  <title>On being a staff engineer</title>
  <link>/blog/2022/08/on-being-a-staff-engineer/</link>
</item>
```

Top level links (which should be absolute links back to the site) being relative:

```xml
<link href="//navoshta.com/" rel="alternate" type="text/html"/>
```

Other times the link to the parent site is sometimes malformed or refers to the same URL as the feed itself (not the parent site)

```xml
<link>https://snapcraft.io//blog/feed</link>
```

All these are trivially solvable, but something to be aware of nonetheless.

## 10. Feeds not respecting ETag and Last-Modified Headers

Including an ETag or Last-Modified header in the body of a request when
fetching a feed is a mechanism to reduce bandwidth.

There is some great documentation on this topic in a post titled ["HTTP Conditional Get for RSS Hackers"](https://fishbowl.pastiche.org/2002/10/21/http_conditional_get_for_rss_hackers)

Which explains these headers are a way to express:

> “If this document has changed since I last looked at it, give me the new
> version. If it hasn't just tell me it hasn't changed and give me nothing.”

The [feedparser](https://feedparser.readthedocs.io/en/latest/) documentation
has a [good
example](https://feedparser.readthedocs.io/en/latest/http-etag.html#etag-and-last-modified-headers)
demonstrating this concept. I'll let the following code snippet explain what's
going on:

```python
>>> import feedparser
>>> d = feedparser.parse('http://feedparser.org/docs/examples/atom10.xml')
>>> d.etag
'"6c132-941-ad7e3080"'
>>> d2 = feedparser.parse('http://feedparser.org/docs/examples/atom10.xml', etag=d.etag)
>>> d2.status
304
>>> d2.feed
{}
>>> d2.entries
[]
>>> d2.debug_message
'The feed has not changed since you last checked, so
the server sent no data.  This is a feature, not a bug!'
```

This makes it relatively cheap and straightforward to check+update feeds which
adhere to this convention. You simply fan out a bunch of requests and discard
any responses with a `304` status.

However not all feeds/servers have logic in place to correctly parse/handle
these optional headers. Some feeds will happily return identical content
repeatedly.

If the feed is being polled periodically, but doesn't change on regular basis
this can be wasted computation + bandwidth. When you're polling many feeds in
bulk this can start to add up.

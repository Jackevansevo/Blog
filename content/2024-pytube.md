Title: TIL: pytube (library for downloading YouTube videos)
Date: 2024-03-27
Status: published
Tags: python

The other day I wanted to quickly download and convert a youtube video to an
audio format so I could record a guitar cover.

I did the usual thing, googled 'Youtube download' and predictably arrived at
a site with a million adverts and 10 differnet download buttons (a sort of
virus lottery).

Being a programmer I figured "There's probably a Python library for that" and
after a little bit of searching I came across the excellent
[pytube](https://pytube.io/en/latest/index.html)

<div class="alert alert-info">
pytube is a lightweight, Pythonic, dependency-free, library (and command-line utility) for downloading YouTube Videos.
</div>

Because I don't always have access to Python + the command line I wrote a thin
web wrapper around the library (code below). Now I can easily fetch videos on the go without
having to visit a shady add-ridden website 🎉

<img class="figure-img img-fluid rounded" src="{static}/images/Screenshot 2024-03-27 174859.png" class="d-block w-100" alt="screenshot of my terrible web wrapper">

```python
import tempfile
from pathlib import Path

from flask import Flask, render_template, request, send_file
from pytube import YouTube

app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        url = request.form["url"]
        extension = request.form.get("extension", "m4a")

        yt = YouTube(url)

        if extension == "mp4":
            stream = (
                yt.streams.filter(progressive=True, file_extension="mp4")
                .order_by("resolution")
                .desc()
                .first()
            )
        elif extension == "m4a":
            stream = (
                yt.streams.filter(only_audio=True).order_by("abr").desc().first()
            )

        temp_file = tempfile.NamedTemporaryFile()
        stream.download(
            output_path="/tmp", filename=temp_file.name, skip_existing=False
        )

        return send_file(
            temp_file.name,
            as_attachment=True,
            download_name=Path(stream.title).with_suffix(f".{extension}").name,
        )

    else:
        return render_template("index.html")


if __name__ == "__main__":
    app.run(debug=True)
```

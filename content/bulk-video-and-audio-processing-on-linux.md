Title: Bulk audio/video processing on Linux
Date: 2023-05-03
Status: published
Tags: Linux, Audio

I recently decided to try my hand recording and producing some screencasts
showing myself building a web application in Django.

<div class="ratio ratio-21x9">
<iframe src="https://www.youtube.com/embed/U278PbXzF2I" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

I found it comfortable record videos in short manageable sections between 5-20
minutes. However doing so resulted in a bunch of videos ...

```
➜  Videos ls -rt podcatcher/*.mp4
podcatcher/ep2.mp4  podcatcher/ep7.mp4  podcatcher/ep5.mp4  podcatcher/ep3.mp4  podcatcher/ep8.mp4   podcatcher/ep12.mp4  podcatcher/ep10.mp4  podcatcher/ep14.mp4
podcatcher/ep1.mp4  podcatcher/ep6.mp4  podcatcher/ep4.mp4  podcatcher/ep9.mp4  podcatcher/ep13.mp4  podcatcher/ep11.mp4  podcatcher/ep15.mp4
```

Unfortunately for me the audio recording with my headset microphone didn't
exactly come out to great. So I found myself needing to some post-processing in
(Audacity)[https://www.audacityteam.org/] to equalize/amplify and compress the
audio streams of each.

# Fixing the bad audio

To figure out how to fix the audio quality I searched YouTube and found this great guide:

<div class="ratio ratio-21x9">
<iframe src="https://www.youtube.com/embed/dQCB72S64L4"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
allowfullscreen></iframe>
</div>

<br>

# Automating the process

I started out painstakingly opening each video in Kdenlive and rendering an
audio only copy of the source video to load into Audacity.

This was before realizing I could just open the videos themselves straight in
Audacity with no issues 🤦 (Audacity will automatically convert an mp4 to an
editable audio stream).

The next piece of the puzzle was to automate the process of improving the audio. I wanted to be able to apply the same quick and dirty equalization/amplification/compression (from the above tutorial) across all of my files.

I found that this could easily be achieved using Audacity custom macros, which
allow you to chain together a sequence of steps you'd typically drive from the
UI in an automated fashion.

<div class="ratio ratio-21x9">
<iframe src="https://www.youtube.com/embed/_DZeio_ansE" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

<img src="{static}/images/Screenshot_20230502_173754.png" alt="Adaucity Manage Macros"  style="max-height: 600px"/>

Running this macro across all my video files creates a bunch of processed audio files in: `~/Documents/macro-output`

```
➜  ~ ls ~/Documents/macro-output
ep10.ogg  ep11.ogg  ep12.ogg  ep13.ogg  ep14.ogg  ep15.ogg  ep1.ogg  ep2.ogg  ep3.ogg  ep4.ogg  ep5.ogg  ep6.ogg  ep7.ogg  ep8.ogg  ep9.ogg
```

# Replacing the original audio

I can then use `ffmpeg` (curtsey of this
[article](https://flyingsound.net/about/articles/replace-video-audio-ffmpeg/))
to create a brand new video from the original, replacing the original audio
track with the newly processed audio files:

```
for f in $(ls *.mp4); do ffmpeg -i $f -i ~/Documents/macro-output/$(basename $f .mp4).ogg -acodec copy -vcodec copy -map 0:v:0 -map 1:a:0 $(basename $f .mp4)-final.mp4; done
```


Which once finished gives me exactly what I need:

```
➜  podcatcher ll *.mp4
-rw-r--r-- 1 jack jack  30M May  2 17:20 ep10-final.mp4
-rw-r--r-- 1 jack jack  34M May  2 16:51 ep10.mp4
-rw-r--r-- 1 jack jack  27M May  2 17:20 ep11-final.mp4
-rw-r--r-- 1 jack jack  30M May  2 16:51 ep11.mp4
-rw-r--r-- 1 jack jack  46M May  2 17:20 ep12-final.mp4
-rw-r--r-- 1 jack jack  52M May  2 16:51 ep12.mp4
-rw-r--r-- 1 jack jack  80M May  2 17:20 ep13-final.mp4
-rw-r--r-- 1 jack jack  89M May  2 16:51 ep13.mp4
-rw-r--r-- 1 jack jack  22M May  2 17:20 ep14-final.mp4
-rw-r--r-- 1 jack jack  25M May  2 16:51 ep14.mp4
-rw-r--r-- 1 jack jack  25M May  2 17:20 ep15-final.mp4
-rw-r--r-- 1 jack jack  28M May  2 16:51 ep15.mp4
-rw-r--r-- 1 jack jack 3.8M May  2 17:20 ep1-final.mp4
-rw-r--r-- 1 jack jack 4.5M May  2 16:51 ep1.mp4
-rw-r--r-- 1 jack jack 8.4M May  2 17:20 ep2-final.mp4
-rw-r--r-- 1 jack jack  11M May  2 16:51 ep2.mp4
-rw-r--r-- 1 jack jack  19M May  2 17:20 ep3-final.mp4
-rw-r--r-- 1 jack jack  22M May  2 16:51 ep3.mp4
-rw-r--r-- 1 jack jack  70M May  2 17:20 ep4-final.mp4
-rw-r--r-- 1 jack jack  77M May  2 16:51 ep4.mp4
-rw-r--r-- 1 jack jack  45M May  2 17:20 ep5-final.mp4
-rw-r--r-- 1 jack jack  51M May  2 16:51 ep5.mp4
-rw-r--r-- 1 jack jack  34M May  2 17:20 ep6-final.mp4
-rw-r--r-- 1 jack jack  37M May  2 16:51 ep6.mp4
-rw-r--r-- 1 jack jack  13M May  2 17:20 ep7-final.mp4
-rw-r--r-- 1 jack jack  15M May  2 16:51 ep7.mp4
-rw-r--r-- 1 jack jack  44M May  2 17:20 ep8-final.mp4
-rw-r--r-- 1 jack jack  49M May  2 16:51 ep8.mp4
-rw-r--r-- 1 jack jack  33M May  2 17:20 ep9-final.mp4
-rw-r--r-- 1 jack jack  37M May  2 16:51 ep9.mp4
```

---

# Conclusion

Overall I'm super pleased with the result. Whilst the quality of the finished
audio still isn't perfect, it's probably the best I can do with my current
setup.

The steps here have saved me quite a bit of painful editing and will hopefully
save me a lot more time in the future.

I'm curious to know what workflows over people have for solving this kind of
task. I'm guessing the majority of people who upload content to Youtube
probably aren't familiar with ffmpeg or Adaucity, would they painstakingly edit
each clip by hand?

I'm guessing  there's better tools in software like Premier Pro, lightworks or
DaVinci that can handle audio processing easily.

Now I just need to figure out how to automate thumbnail creation the whole
process will be super smooth!

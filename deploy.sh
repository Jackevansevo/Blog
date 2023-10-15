#!/bin/bash
pelican content -o output -s publishconf.py
ghp-import output -b gh-pages
git push git@github.com:Jackevansevo/Jackevansevo.github.io.git gh-pages:master -f

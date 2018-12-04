#!/usr/bin/python3

from __future__ import unicode_literals
import sys, os
from pathlib import Path
import youtube_dl
from gmusicapi import Musicmanager

args = sys.argv[:]
del args[0]

if len(args) < 1:
    sys.exit('Please include the video url.')

os.chdir(Path.home())
Path('.yt_to_play').mkdir(exist_ok=True)
os.chdir('.yt_to_play')
Path('download_temp').mkdir(exist_ok=True)
os.chdir('download_temp')

ydl_opts = {
    'format': 'bestaudio/best',
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': 'mp3',
        'preferredquality': '192',
    }],
    'outtmpl': '%(title)s.%(ext)s',
    'download_archive': '../downloaded.txt',
}

with youtube_dl.YoutubeDL(ydl_opts) as ydl:
    ydl.download(args)

print('Uploading...')
mm = Musicmanager()
oauth = Path('../oauth.cred')
if not(oauth.exists() and oauth.is_file()):
    mm.perform_oauth(oauth)
mm.login(oauth)
mm.upload([os.path.join(os.getcwd(), f) for f in os.listdir(os.getcwd())])
for f in os.listdir(os.getcwd()):
    os.remove(f)

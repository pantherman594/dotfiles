#!/usr/bin/python
import json
from subprocess import Popen, PIPE

out, err = Popen(['curl', '-s', 'https://api.reddit.com/r/earthporn+spaceporn/top?t=day&limit=100', '-A', 'linux:com.pantherman594.background:v0.1'], stdin=PIPE, stdout=PIPE, stderr=PIPE).communicate()
data = json.loads(out)

largestRatio = 0
largestUrl = ''
for post in data['data']['children']:
    imageData = post['data']['preview']['images'][0]['source']
    if imageData['height'] < 700: continue
    ratio = imageData['width'] / imageData['height']
    if ratio > 2.2: # ensure the image is widescreen
        largestUrl = imageData['url']
        break
    if ratio > largestRatio:
        largestRatio = ratio
        largestUrl = imageData['url']
print(largestUrl)
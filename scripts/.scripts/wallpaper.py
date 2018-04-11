#!/usr/bin/python
import json
from subprocess import Popen, PIPE

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

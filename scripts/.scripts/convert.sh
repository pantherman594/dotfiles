#!/bin/bash

for f in "$@"; do
  out="${f%.*}.mp4"
  if [[ -f $out ]]; then
    echo "Skipping $f because $out already exists."
  else
    echo "Encoding $f..."
    HandBrakeCLI --preset-import-file -Z "720p" -i "$f" -o "$out"
  fi
done

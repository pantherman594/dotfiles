#!/bin/bash

for f in *.heic
do
	name=$(echo $f | cut -d'.' -f1)
	echo $name
	modifier=0
	new=$name.jpg
	while [ -f $new ]
	do
		echo "$new exists"
		modifier=$(( modifier + 1 ))
		new=${name}_$modifier.jpg
	done
	convert $name.heic $new
	mogrify $new
	exiftool -TagsFromFile $name.heic $new
	rm $name.heic
done

#!/bin/bash

if pgrep -u $UID -x i3-nagbar >/dev/null; then i3-msg exit; fi

i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'
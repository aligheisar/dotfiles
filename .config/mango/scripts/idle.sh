#!/usr/bin/bash

swayidle \
	timeout 600 'wlr-dpms off && swaylock -f -c 000000' \
	resume 'wlr-dpms on && ~/.config/mango/scripts/restart-wlsunset.sh' \
	timeout 180 'dimland' \
	resume '~/.config/mango/scripts/exit-dim.sh'

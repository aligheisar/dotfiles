#!/bin/bash

if pgrep mpd >/dev/null; then
	exit 0
else
	exit 1
fi

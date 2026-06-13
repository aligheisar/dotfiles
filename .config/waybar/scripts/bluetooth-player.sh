#!/usr/bin/env bash

# Choose preferred player
PLAYER=$(playerctl -l 2>/dev/null | grep -m 1 "bluez" || playerctl -l 2>/dev/null | head -n 1)

# If no player found, exit early
if [[ -z "$PLAYER" ]]; then
    echo '{}'
    exit 0
fi

STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)

if [[ "$STATUS" == "Playing" ]]; then
    ICON="▶"
elif [[ "$STATUS" == "Paused" ]]; then
    ICON="⏸"
else
    echo '{"text":"Not playing","tooltip":"No media","class":"idle"}'
    exit 0
fi

TITLE=$(playerctl -p "$PLAYER" metadata title 2>/dev/null | cut -c1-50)
ARTIST=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null | cut -c1-30)

TEXT=""
if [[ -n "$TITLE" && -n "$ARTIST" ]]; then
    TEXT="$TITLE - $ARTIST"
elif [[ -n "$TITLE" ]]; then
    TEXT="$TITLE"
else
    TEXT="Unknown"
fi

TOOLTIP=$(printf "%s\n%s" "$TITLE" "$ARTIST")

echo "{\"text\":\"$ICON $TEXT\",\"tooltip\":\"$TOOLTIP\",\"class\":\"${STATUS,,}\"}"


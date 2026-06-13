#!/usr/bin/env bash

print_keymode() {
	keymode=$(mmsg get keymode | jq -r .keymode)

	if [ "$keymode" = "default" ]; then
    echo '{"text":"","class":"hidden"}'
	else
		echo "{\"text\":\"$keymode\"}"
	fi
}

print_keymode

mmsg watch keymode | while read -r _; do
	print_keymode
done

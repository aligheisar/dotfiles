#!/usr/bin/env bash

print_layout() {
	layout=$(mmsg get keyboardlayout)

	case "$layout" in
		*"English (US)"*) echo "EN" ;;
		*"Persian"*) echo "FA" ;;
		*) echo "??" ;;
	esac
}

print_layout

mmsg watch keyboardlayout | while read -r _; do
  print_layout
done

#!/usr/bin/env bash

MONITOR="${1:-HDMI-A-1}"

render() {
    jq -r '
    .tags
    | map(
        if .is_active then
            "<span foreground=\"#89b4fa\"><b>[" + (.index|tostring) + "]</b></span>"
        elif .is_urgent then
            "<span foreground=\"#f38ba8\">" + (.index|tostring) + "</span>"
        elif .client_count > 0 then
            "<span foreground=\"#a6e3a1\">" + (.index|tostring) + "</span>"
        else
            "<span foreground=\"#6c7086\">" + (.index|tostring) + "</span>"
        end
    )
    | join("  ")
    '
}

mmsg watch tags "$MONITOR" | while read -r line; do
    echo "$line" | render
done

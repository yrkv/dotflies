#!/bin/sh

pid="$(niri msg -j focused-window | jq '.pid')"
#pid="$(hyprctl activewindow | grep pid | grep -o '[0-9]*')"

ppid="$(ps -o pid= --ppid "$pid" | xargs)"

alacritty --working-directory "$(readlink "/proc/$ppid/cwd")"
#foot --working-directory="$(readlink "/proc/$ppid/cwd")"


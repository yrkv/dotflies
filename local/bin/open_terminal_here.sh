#!/bin/sh

pid="$(niri msg -j focused-window | jq '.pid')"
#pid="$(hyprctl activewindow | grep pid | grep -o '[0-9]*')"

ppid="$(ps -o pid= --ppid "$pid" | xargs)"

cwd="$(readlink "/proc/$ppid/cwd")"

case "$cwd" in
    /var/home|/var/home/*)
        cwd="/home${cwd#/var/home}"
        ;;
esac

cd "$cwd"
alacritty --working-directory "$cwd"
#alacritty --working-directory "/home/yegor/.local/bin"
#foot --working-directory="$(readlink "/proc/$ppid/cwd")"


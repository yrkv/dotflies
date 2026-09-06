#!/usr/bin/env fish

if not set -q SSH_CWD_TARGETS
  exit
end


set ssh_wrapper _ssh_cwd.sh

set pid1 (niri msg -j focused-window | jq '.pid')

if test (ps -o comm= -p $pid1) != alacritty
  exec alacritty
end

set pid2 (ps -o pid= --ppid $pid1 | string trim)

set cwd (readlink /proc/$pid2/cwd)

if string match -q '/var/home*' $cwd
  set cwd (string replace '/var/home' '/home' $cwd)
end

set args alacritty --working-directory $cwd

set pid3 (ps -o pid= --ppid $pid2 | string trim)

if test (ps -o comm= -p $pid3) = ssh
  set ssh_args (string split0 < /proc/$pid3/cmdline)

  set target $ssh_args[2]

  if contains -- $target $SSH_CWD_TARGETS
    if test -f /tmp/ssh-cwd-$pid3
      set remote_cwd (cat /tmp/ssh-cwd-$pid3)
      set escaped_remote_cwd (string escape -- $remote_cwd)
      set args $args -e fish -C "set -x SSH_CWD '$escaped_remote_cwd'; $ssh_wrapper $target"
    else
      set args $args -e fish -C "set -e SSH_CWD; $ssh_wrapper $target"
    end
  end
end

cd $cwd
exec $args


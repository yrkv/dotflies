set fish_greeting # disable greeting

if not contains ~/.local/bin $PATH
  set -gx PATH ~/.local/bin $PATH
end

if test -e ~/.config/fish/hosts/$HOSTNAME.fish
  source ~/.config/fish/hosts/$HOSTNAME.fish
end

if status is-interactive
  for file in ~/.config/fish/conf.interactive.d/*.fish
    source $file
  end
end

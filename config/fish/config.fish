set fish_greeting # disable greeting

export UV_PYTHON_PREFERENCE=only-managed

if not contains ~/.local/bin $PATH
  set -gx PATH ~/.local/bin $PATH
end

if test -e ~/.config/fish/hosts/(hostname).fish
  source ~/.config/fish/hosts/(hostname).fish
end

if status is-interactive
  for file in ~/.config/fish/conf.interactive.d/*.fish
    source $file
  end
end


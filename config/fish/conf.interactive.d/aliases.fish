
alias ":q"="exit"
alias "cd.."="cd .."

if require_all -q eza
  alias ls="eza"
  alias lt="eza --tree --level=3"
end

if require_all nvim
  export VISUAL=nvim
  export EDITOR=nvim

  alias v nvim
  alias vi nvim
  alias vim nvim
end


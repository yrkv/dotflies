set fish_greeting # disable greeting

if not contains ~/.local/bin $PATH
  set -gx PATH ~/.local/bin $PATH
end

function require_deps
  for d in $argv
    if not command -q $d
      echo "Warning: missing dependency: $d"
      return 1
    end
  end
  return 0
end


alias ":q"="exit"
alias "cd.."="cd .."
alias "cd."="cd ."

if require_deps eza
  alias ls="eza"
  alias lt="eza --tree --level=3"
end

if require_deps nvim
  export VISUAL=nvim
  export EDITOR=nvim

  alias v nvim
  alias vi nvim
  alias vim nvim
end


if status is-interactive
  # Commands to run in interactive sessions can go here

  # venv.fish - Automatically activate/deactivate virtualenv in fish shell
  # from: https://gist.github.com/tommyip/cf9099fa6053e30247e5d0318de2fb9e
  function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
    status --is-command-substitution; and return
    # Check if we are inside a git directory
    if git rev-parse --show-toplevel &>/dev/null
      set gitdir (realpath (git rev-parse --show-toplevel))
      set cwd (pwd -P)
      # While we are still inside the git directory, find the closest
      # virtualenv starting from the current directory.
      while string match "$gitdir*" "$cwd" &>/dev/null
        if test -e "$cwd/.venv/bin/activate.fish"
          source "$cwd/.venv/bin/activate.fish" &>/dev/null
          return
        else
          set cwd (path dirname "$cwd")
        end
      end
    end
    # If virtualenv activated but we are not in a git directory, deactivate.
    if test -n "$VIRTUAL_ENV"
      deactivate
    end
  end

  if require_deps git
    __auto_source_venv
  end

  if require_deps direnv
    direnv hook fish | source
  end

end

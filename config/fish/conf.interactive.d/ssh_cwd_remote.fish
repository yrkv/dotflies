# Server side of ssh-cwd
# Sends the PWD back through a socket from within an ssh session,
# so the local side of ssh-cwd can know where any ssh is navigated to.

if set -q SSH_CWD_SOCKET; and require_all -q nc

  # if SSH_CWD_SOCKET is set, send the content of PWD anytime it's changed.
  function __send_ssh_cwd --on-variable PWD
    printf '%s\n' "$PWD" | nc -U "$SSH_CWD_SOCKET"
  end
  __send_ssh_cwd

  # When fish exits, delete file at SSH_CWD_SOCKET if it exists.
  # SSH_CWD_SOCKET_CLEANUP is used to avoid doing so on nested fish instances.
  if not set -q SSH_CWD_SOCKET_CLEANUP
    set -gx SSH_CWD_SOCKET_CLEANUP 1

    function __cleanup_ssh_cwd_socket --on-event fish_exit
      # check again in case something unset it...
      if set -q SSH_CWD_SOCKET
        rm -f -- "$SSH_CWD_SOCKET"
      end
    end
  end
end


set -gx SSH_CWD_TARGETS data antor

function ssh
  switch $argv[1]
    case $SSH_CWD_TARGETS
      _ssh_cwd.sh $argv
    case '*'
      command ssh $argv
  end
end

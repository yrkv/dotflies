#!/bin/sh

id=$$
socket="/tmp/ssh-cwd-$id.sock"

python3 - "$socket" "/tmp/ssh-cwd-$id" <<'PY' &
import socket
import sys
from pathlib import Path

sock_path = sys.argv[1]
file_path = Path(sys.argv[2])

s = socket.socket(socket.AF_UNIX)
s.bind(sock_path)
s.listen(1)

while True:
    conn, _ = s.accept()
    with conn:
        # os.environ['SSH_CWD_SOCKET'] = conn.recv(4096).decode().strip()
        cwd = conn.recv(4096).decode().strip()
        file_path.write_text(f'{cwd}\n')
PY
#listener_pid=$!

exec /usr/bin/ssh "$@" \
  -t -R "$socket:$socket" \
  "export SSH_CWD_SOCKET='$socket';" \
  'cd $HOME;' \
  "cd $SSH_CWD;" \
  "exec bash -i;"

# Note: an unset SSH_CWD will result in just `cd ;`, which just goes to home.


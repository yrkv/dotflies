
if not contains ~cs240/bin $PATH
  set -gx PATH ~cs240/bin $PATH
end

if require_deps nvim-linux-x86_64.appimage
  alias nvim nvim-linux-x86_64.appimage
end



# Check that all specified commands or functions exist.
# Returns 0 if all dependencies are available, otherwise 1.
# Use --quiet to suppress warnings about missing dependencies.
function require_all --description 'Check that all specified commands or functions exist'
  argparse 'q/quiet' -- $argv
  or return 2

  for d in $argv
    if not command -q $d; and not functions -q $d
      if not set -q _flag_quiet
        echo "Warning: missing dependency: $d"
      end
      return 1
    end
  end
  return 0
end


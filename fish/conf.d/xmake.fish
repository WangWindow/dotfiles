set -l xmake_completions /usr/share/xmake/scripts/completions/register-completions.fish
test -f $xmake_completions; and source $xmake_completions

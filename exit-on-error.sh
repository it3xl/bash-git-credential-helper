set -euf +x -o pipefail

echo @@ $(basename "$BASH_SOURCE") start>&2

exit_code=${1-}

echo status is $exit_code

(( 0 < $exit_code )) && echo error status $exit_code || echo good status $exit_code

echo @@ $(basename "$BASH_SOURCE") end>&2
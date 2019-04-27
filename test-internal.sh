tput reset
set -e -uf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo '$ '$(basename "$BASH_SOURCE")


git_cred_path="$invoke_path/git-cred.sh"

echo ''
echo @ Testing the intro
echo ======================================================================
"$git_cred_path" 2>/dev/null
echo --Accepted if empty---------------------------------------------------

echo ''
echo @ Testing the help
echo ======================================================================
"$git_cred_path"  help>/dev/null
echo --Accepted------------------------------------------------------------

echo ''
echo @ Testing the fail method for init
echo ======================================================================
export GIT_CRED_DO_NOT_EXIT=123
"$git_cred_path"  init
export GIT_CRED_DO_NOT_EXIT=
echo --Accepted------------------------------------------------------------

echo ''
echo @ Testing the fail method for init-by-url
echo ======================================================================
export GIT_CRED_DO_NOT_EXIT=123
"$git_cred_path"  init-by-url
export GIT_CRED_DO_NOT_EXIT=
echo --Accepted------------------------------------------------------------





#echo sleep...
#sleep 20s
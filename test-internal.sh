tput reset
set -e -uf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo '$ '$(basename "$BASH_SOURCE")


git_cred_path="$invoke_path/git-cred.sh"
export GIT_CRED_DO_NOT_EXIT=123

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
"$git_cred_path"  init
echo --Accepted------------------------------------------------------------

echo ''
echo @ Testing the fail method for init
echo ======================================================================
"$git_cred_path"  init  some-remote
echo --Accepted------------------------------------------------------------

echo ''
echo @ Testing the fail method for init-by-url
echo ======================================================================
"$git_cred_path"  init-by-url
echo --Accepted------------------------------------------------------------





#echo sleep...
#sleep 20s
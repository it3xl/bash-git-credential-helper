tput reset
set -e -uf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo '$ '$(basename "$BASH_SOURCE")



# Clean ups previous tests.
test_repos="$invoke_path/te st"
if [[ -d "$test_repos" ]]; then
  rm -rf "$test_repos"
fi
mkdir -p "$test_repos"

git_cred_source="$invoke_path/git-cred.sh"
git_cred_dir="$test_repos/git cred"
mkdir -p "$git_cred_dir"
git_cred_path="$git_cred_dir/git-cred.sh"

cp -f  "$git_cred_source"  "$git_cred_path"

cd "$test_repos"

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
echo --Done----------------------------------------------------------------

echo ''
echo @ Testing the fail method for init-by-remote '(no remote name)'
echo ======================================================================
"$git_cred_path"  init-by-remote
echo --Done----------------------------------------------------------------

echo ''
echo @ Testing the fail method for init-by-remote '(no credentials)'
echo ======================================================================
"$git_cred_path"  init-by-remote  some-remote
echo --Done----------------------------------------------------------------

echo ''
echo @ Testing the fail method for init-by-url
echo ======================================================================
"$git_cred_path"  init-by-url
echo --Done----------------------------------------------------------------





#echo sleep...
#sleep 20s
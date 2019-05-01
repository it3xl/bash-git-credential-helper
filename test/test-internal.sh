tput reset
set -e -uf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo '$ '$(basename "$BASH_SOURCE")



# Clean ups previous tests.
test_repos="$invoke_path/test internal"
if [[ -d "$test_repos" ]]; then
  rm -rf "$test_repos"
fi
mkdir -p "$test_repos"

git_cred_dir="$test_repos/git cred"
mkdir -p "$git_cred_dir"
git_cred_path="$git_cred_dir/git-cred.sh"

git_cred_source="$invoke_path/../git-cred.sh"
cp -f  "$git_cred_source"  "$git_cred_path"

cd "$test_repos"

export GIT_CRED_DO_NOT_EXIT=123

echo
echo @ Produces the intro.
echo ======================================================================
"$git_cred_path" 2>/dev/null
echo --Accepted if empty---------------------------------------------------

echo
echo @ Produces the help
echo ======================================================================
"$git_cred_path"  help>/dev/null
echo --Done----------------------------------------------------------------

echo
echo @ Fails if it is not a Git-repo root.
echo ======================================================================
"$git_cred_path"  init
echo --Done----------------------------------------------------------------

echo
echo @ Fails if it is a subfolder in a Git-repo directory tree.
echo ======================================================================
git init && echo
mkdir oppa
cd oppa

"$git_cred_path"  init

cd ..
echo --Done----------------------------------------------------------------

echo
echo @ Fails for init '(no remote name or an arbitrary key)'
echo ======================================================================
"$git_cred_path"  init
echo --Done----------------------------------------------------------------

echo
echo @ Fails for init '(no credentials for a remote name)'
echo ======================================================================
"$git_cred_path"  init  some-remote
echo --Done----------------------------------------------------------------


echo
echo @ Fails for init '(there is no such a remote name)'
echo ======================================================================
export git_cred_username_my_origin=some-login
export git_cred_password_my_origin=some-password

"$git_cred_path"  init  my_origin
echo --Done----------------------------------------------------------------

echo
echo @ Fails for init '(no credentials for an URL)'
echo ======================================================================
"$git_cred_path"  init  some-text  http://example.com/my.repo.git
echo --Done----------------------------------------------------------------

echo
echo @ Notifies about an unknow action
echo ======================================================================
"$git_cred_path"  some-action
echo --Done----------------------------------------------------------------





#echo sleep...
#sleep 20s
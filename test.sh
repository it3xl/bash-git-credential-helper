set -euf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


GIT_CRED_DO_NOT_EXIT=123



test_repo="$invoke_path/git-cred-test-repo"
if [[ -d "$test_repo" ]]; then
  rm -rf $test_repo
fi

mkdir "$test_repo"

# Not git-cred requires work under a target Git-repo directory.
cd "$test_repo"

remote=it3xl

echo @ Creating test Git repo.
git init
git remote add $remote https://example.com/my.git


git_cred_username_it3xl=some-login
git_cred_password_it3xl=some-password


git_cred="$invoke_path/git-cred.sh"

echo ''
echo Installing git-cred as a credential helper.
source "$git_cred"  $remote  init

echo ''
echo Testing git-cred as a credential helper.
source "$git_cred"  $remote


echo ''
echo Everything is OK
echo sleep...
sleep 20s
set +e -uf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


GIT_CRED_DO_NOT_EXIT=123



test_repos="$invoke_path/test"
if [[ -d "$test_repos" ]]; then
  rm -rf $test_repos
fi


test_repo_remote="$test_repos/test-repo-remote-name"
mkdir -p "$test_repo_remote"

cd "$test_repo_remote"

git init >null

remote_name=origin
git remote add $remote_name https://example.com/my.git

git_cred_username_origin=some-login
git_cred_password_origin=some-password


git_cred_path="$invoke_path/git-cred.sh"

# Installing git-cred as a Git credential helper.
source "$git_cred_path"  init  $remote_name

# Testing git-cred as a Git credential helper.
source "$git_cred_path"  get  $remote_name  get

# Testing git-cred as a Git credential helper.
#source "$git_cred_path"  get  $remote_name 


echo ''
echo Everything is OK
#echo sleep...
#sleep 20s
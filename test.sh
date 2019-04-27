set -e -uf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


git_cred_path="$invoke_path/git-cred.sh"


echo @ Testing the intro
echo ======================================================================
source "$git_cred_path">/dev/null
echo --Accepted------------------------------------------------------------

echo ''
echo @ Testing the help
echo ======================================================================
source "$git_cred_path"  help>/dev/null
echo --Accepted------------------------------------------------------------

echo ''
echo @ Testing the fail method for init
echo ======================================================================
GIT_CRED_DO_NOT_EXIT=123
source "$git_cred_path"  init
GIT_CRED_DO_NOT_EXIT=
echo --Accepted------------------------------------------------------------

echo ''
echo @ Testing the fail method for init-by-url
echo ======================================================================
GIT_CRED_DO_NOT_EXIT=123
source "$git_cred_path"  init-by-url
GIT_CRED_DO_NOT_EXIT=
echo --Accepted------------------------------------------------------------


# Clears previous tests.
test_repos="$invoke_path/test"
if [[ -d "$test_repos" ]]; then
  rm -rf $test_repos
fi

echo ''
echo @ Testing a repo with a remote name
echo ======================================================================

test_repo_remote="$test_repos/test-repo-remote-name"
mkdir -p "$test_repo_remote"

cd "$test_repo_remote"

git init >/dev/null

remote_name=origin
git remote add $remote_name https://example.com/my.git

git_cred_username_origin=some-login
git_cred_password_origin=some-password



# Installing git-cred as a Git credential helper.
source "$git_cred_path"  init  $remote_name

# Testing git-cred as a Git credential helper.
source "$git_cred_path"  get  $remote_name  get

# Ignoring of the store action of Git helper API.
source "$git_cred_path"  get  $remote_name  store

# Ignoring of the erase action of Git helper API.
source "$git_cred_path"  get  $remote_name erase

# Ignoring of an empty action of Git helper API.
source "$git_cred_path"  get  $remote_name 

echo --Accepted------------------------------------------------------------

echo ''
echo @ Testing a repo without a remote name
echo ======================================================================

test_repo_url="$test_repos/test-repo-without-remote-name"
mkdir -p "$test_repo_url"

cd "$test_repo_url"

git init >/dev/null

remote_url=https://example.com/my.git

git_cred_username=another-login
git_cred_password=another-password



# Installing git-cred as a Git credential helper.
source "$git_cred_path"  init-by-url  $remote_url

# Testing git-cred as a Git credential helper.
source "$git_cred_path"  get-by-url  $remote_url  get

# Ignoring of the store action of Git helper API.
source "$git_cred_path"  get-by-url  $remote_url  store

# Ignoring of the erase action of Git helper API.
source "$git_cred_path"  get-by-url  $remote_url erase

# Ignoring of an empty action of Git helper API.
source "$git_cred_path"  get-by-url  $remote_url 

echo --Accepted------------------------------------------------------------







#echo sleep...
#sleep 20s
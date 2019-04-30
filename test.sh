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


echo ''
echo @ Testing a remote name usage
echo ======================================================================

test_repo_remote="$test_repos/repo with remote name"
mkdir -p "$test_repo_remote"

cd "$test_repo_remote"

git init >/dev/null

remote_name=origin
git remote add $remote_name https://example.com/my.git

git_cred_username_origin=some-login
git_cred_password_origin=some-password



# Installing git-cred as a Git credential helper.
source "$git_cred_path"  init-by-remote  $remote_name

remote_url=$(git remote get-url $remote_name)

# Testing git-cred as a Git credential helper.
source "$git_cred_path"  get-by-remote  $remote_name  get

# Ignoring of the store action of Git helper API.
source "$git_cred_path"  get-by-remote  $remote_name  store

# Ignoring of the erase action of Git helper API.
source "$git_cred_path"  get-by-remote  $remote_name erase

# Ignoring of an empty action of Git helper API.
source "$git_cred_path"  get-by-remote  $remote_name 

echo --Done----------------------------------------------------------------

echo ''
echo @ Testing a remote URL usage
echo ======================================================================

test_repo_url="$test_repos/test repo without remote name"
mkdir -p "$test_repo_url"

cd "$test_repo_url"

git init >/dev/null

remote_url=https://example.com/my.git

git_cred_username_some_text=another-login
git_cred_password_some_text=another-password



# Installing git-cred as a Git credential helper.
source "$git_cred_path"  init-by-url  some-text  $remote_url

# Testing git-cred as a Git credential helper.
source "$git_cred_path"  get-by-url  some-text  get

# Ignoring of the store action of Git helper API.
source "$git_cred_path"  get-by-url  some-text  store

# Ignoring of the erase action of Git helper API.
source "$git_cred_path"  get-by-url  some-text erase

# Ignoring of an empty action of Git helper API.
source "$git_cred_path"  get-by-url  some-text

echo --Done----------------------------------------------------------------


echo ''
echo @ Multiple installations are not a trouble
echo ======================================================================

cd "$test_repo_remote"

# Installing git-cred as a Git credential helper.
source "$git_cred_path"  init-by-remote  $remote_name
source "$git_cred_path"  init-by-remote  $remote_name
source "$git_cred_path"  init-by-remote  $remote_name

# Testing git-cred as a Git credential helper.
source "$git_cred_path"  get-by-remote  $remote_name  get

# Ignoring of the store action of Git helper API.
source "$git_cred_path"  get-by-remote  $remote_name  store

echo --Done----------------------------------------------------------------

echo ''
echo @ Testing a remote name with a dash
echo ======================================================================

cd "$test_repo_remote"

remote_dashed_name=ori-gin
git remote add $remote_dashed_name https://example.com/another.git

# Here replace dash in remote name with underscore.
git_cred_username_ori_gin=some-login
git_cred_password_ori_gin=some-password



# Installing git-cred as a Git credential helper.
source "$git_cred_path"  init-by-remote  $remote_dashed_name

# Testing git-cred as a Git credential helper.
source "$git_cred_path"  get-by-remote  $remote_dashed_name  get

# Ignoring of the store action of Git helper API.
source "$git_cred_path"  get-by-remote  $remote_dashed_name  store

# Ignoring of the erase action of Git helper API.
source "$git_cred_path"  get-by-remote  $remote_dashed_name erase

# Ignoring of an empty action of Git helper API.
source "$git_cred_path"  get-by-remote  $remote_dashed_name 

echo --Done----------------------------------------------------------------







#echo sleep...
#sleep 20s
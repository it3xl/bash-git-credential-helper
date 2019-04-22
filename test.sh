set -euf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


user_name_var=some-login
user_password_var=some-password


test_repo="$invoke_path/git-cred-test-repo"
if [[ -d "$test_repo" ]]; then
  rm -rf test_repo
fi

mkdir "$test_repo"

# Not git-cred requires work under a target Git-repo directory.
cd "$test_repo"

echo @ Creating test Git repo.
git init
git remote add it3xl-remote https://github.com/it3xl/bash-git-credential-helper.git
git remote add some-remote https://example.com/my-repo.git

git_cred="$invoke_path/git-cred.sh"

echo ''
echo Testing of empty Git-repo URL
source "$git_cred"  init  user_name_var  user_password_var

echo ''
echo error is $?

echo ''
echo Testing with a Git-repo URL
source "$git_cred"  init  user_name_var  user_password_var  https://my.git.repo

echo ''
echo error is $?

echo ''
echo Testing main behavior.
source "$git_cred"

echo ''
echo error is $?


echo ''
echo sleep...
sleep 20s
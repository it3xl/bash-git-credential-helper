set -euf +x -o pipefail

## How to set-up everything.
#
# 1. Define required variables
#$ user_name_variable_name=some-user-name
#$ user_password_variable_name=some-user-password
#
# 2. Define GIT_ASKPASS variable; define user-name in "git config credential" by calling
# (provide repository_url parameter only if you have multiple remotes in your Git-repo)
#$ source env-to-credential.sh  init  user_name_variable_name  user_password_variable_name  [repository_url]

## How it works
# Git will call this script automatically without any parameters as
#$ source env-to-credential.sh

## How to test
#
# Get user name
#$ source env-to-credential.sh Username
#
# Get user's password
#$ source env-to-credential.sh Password



echo @@ $(basename "$BASH_SOURCE") start>&2

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

action=${1-}

# Approaches are taken from
# https://stackoverflow.com/questions/8536732/can-i-hold-git-credentials-in-environment-variables
# https://git-scm.com/docs/gitcredentials
#
# Mimics Jenkins logic accordingly with (not tested yet)
# https://github.com/jenkinsci/git-client-plugin/blob/master/src/main/java/org/jenkinsci/plugins/gitclient/CliGitAPIImpl.java#L2022


if [[ "$action" = "init" ]]; then
  user_name_variable_name=${2-}
  user_password_variable_name=${3-}
  repository_url=${4-}

  is_inside_git_work_tree=1;
  git rev-parse --is-inside-work-tree > /dev/null 2>&1  ||  is_inside_git_work_tree=0
  if (( $is_inside_git_work_tree != 1 )); then
    echo @ A test Git repo is created
    git init
  fi;
  #
  echo @ Remember credential variables
  #
  GIT_ASKPASS_user_name_variable_name=$user_name_variable_name
  echo GIT_ASKPASS_user_name_variable_name = $GIT_ASKPASS_user_name_variable_name
  export GIT_ASKPASS_user_name_variable_name
  #
  GIT_ASKPASS_user_password_variable_name=$user_password_variable_name
  echo GIT_ASKPASS_user_password_variable_name = $GIT_ASKPASS_user_password_variable_name
  export GIT_ASKPASS_user_password_variable_name

  echo @ Initializing a user-name in Git config
  echo git config credential${repository_url:+.${repository_url}}.username  ${!GIT_ASKPASS_user_name_variable_name}
  git config credential${repository_url:+.${repository_url}}.username  ${!GIT_ASKPASS_user_name_variable_name}
  #
  if (( $is_inside_git_work_tree != 1 )); then
    echo @ The test Git repo is deleted
    rm -rf '.git'
  fi;

  echo @ Initializing GIT_ASKPASS
  #
  GIT_ASKPASS=$invoke_path/$BASH_SOURCE
  export GIT_ASKPASS
  echo GIT_ASKPASS = $GIT_ASKPASS
  
elif [[ "$action" = "Username" ]]; then
  # For testing. Used by Jenkins too.
  echo @ Providing a user name>&2
  echo GIT_ASKPASS_user_name_variable_name is $GIT_ASKPASS_user_name_variable_name>&2
  echo ${!GIT_ASKPASS_user_name_variable_name}
elif [[ "$action" = "Password" ]]; then
  # For testing. Used by Jenkins too.
  echo @ Providing a user password>&2
  echo GIT_ASKPASS_user_password_variable_name is $GIT_ASKPASS_user_password_variable_name>&2
  echo ${!GIT_ASKPASS_user_password_variable_name}
else
  echo @ Providing a user password for Git>&2
  echo GIT_ASKPASS_user_password_variable_name is $GIT_ASKPASS_user_password_variable_name>&2
  echo ${!GIT_ASKPASS_user_password_variable_name}
fi




echo @@ $(basename "$BASH_SOURCE") end>&2


























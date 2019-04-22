set -euf +x -o pipefail

## How to set-up everything.
#
# 1. Define credential environment variables.
#$ user_name_variable_name=some-login
#$ user_password_variable_name=some-password
#
# 2. Initialize behaviour.
#$ source git-cred.sh  init  user_name_variable_name  user_password_variable_name  [repository_url]
# (provide repository_url parameter only if you have multiple remotes in your Git-repo)
#
# 3. If you what to use GIT_ASKPASS approach then add a user name to a target Git-repo configuration by calling
#$ git config credential" 
#$ source git-cred.sh  config-username

## How it works
# Git will call this script automatically without any parameters as
#$ source git-cred.sh

## How to test
#
# Get user name
#$ source git-cred.sh Username
#
# Get user's password
#$ source git-cred.sh Password



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

  echo @ Remember credential variables
  #
  git_cred_user_name_variable_name=$user_name_variable_name
  echo git_cred_user_name_variable_name = $git_cred_user_name_variable_name
  export git_cred_user_name_variable_name
  #
  git_cred_user_password_variable_name=$user_password_variable_name
  echo git_cred_user_password_variable_name = $git_cred_user_password_variable_name
  export git_cred_user_password_variable_name


  echo @ Initializing GIT_ASKPASS
  #
  GIT_ASKPASS=$invoke_path/$BASH_SOURCE
  export GIT_ASKPASS
  echo GIT_ASKPASS = $GIT_ASKPASS
  
elif [[ "$action" = "config-username" ]]; then

  is_inside_git_work_tree=1;
  git rev-parse --is-inside-work-tree > /dev/null 2>&1  ||  is_inside_git_work_tree=0
  if (( $is_inside_git_work_tree != 1 )); then
    echo @ A test Git repo is created
    git init
  fi;

  echo @ Initializing a user-name in Git config
  echo git config credential${repository_url:+.${repository_url}}.username  ${!git_cred_user_name_variable_name}
  git config credential${repository_url:+.${repository_url}}.username  ${!git_cred_user_name_variable_name}

  if (( $is_inside_git_work_tree != 1 )); then
    echo @ The test Git repo is deleted
    rm -rf '.git'
  fi;

elif [[ "$action" = "Username" ]]; then
  # For testing. Used by Jenkins too.
  echo @ Providing a user name>&2
  echo git_cred_user_name_variable_name is $git_cred_user_name_variable_name>&2
  echo ${!git_cred_user_name_variable_name}
elif [[ "$action" = "Password" ]]; then
  # For testing. Used by Jenkins too.
  echo @ Providing a user password>&2
  echo git_cred_user_password_variable_name is $git_cred_user_password_variable_name>&2
  echo ${!git_cred_user_password_variable_name}
else
  echo @ Providing a user password for Git>&2
  echo git_cred_user_password_variable_name is $git_cred_user_password_variable_name>&2
  echo ${!git_cred_user_password_variable_name}
fi




echo @@ $(basename "$BASH_SOURCE") end>&2


























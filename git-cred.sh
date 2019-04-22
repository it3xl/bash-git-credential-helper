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

## How it works
# Git will call this script automatically without any parameters as
#$ source git-cred.sh

## A health check
#$ source git-cred.sh

# Approaches are taken from
# https://git-scm.com/docs/gitcredentials
# https://git-scm.com/docs/api-credentials
# https://git-scm.com/docs/git-config
# https://git-scm.com/docs/git-credential
# https://git-scm.com/docs/git-credential-store
# Bash custom Git credential helper (Jenkins Pipeline): https://alanedwardes.com/blog/posts/git-username-password-environment-variables/
# Python custom Git credential helper: https://pratz.github.io/custom-git-credential-helper
# GIT_ASKPASS usage: https://stackoverflow.com/questions/8536732/can-i-hold-git-credentials-in-environment-variables/54888724#54888724
# Jenkins askpass implementation. https://github.com/jenkinsci/git-client-plugin/blob/master/src/main/java/org/jenkinsci/plugins/gitclient/CliGitAPIImpl.java#L2022


echo @@ $(basename "$BASH_SOURCE") start>&2

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

action=${1-}

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

  is_inside_git_work_tree=1;
  git rev-parse --is-inside-work-tree > /dev/null 2>&1  ||  is_inside_git_work_tree=0
  if (( $is_inside_git_work_tree != 1 )); then
    echo @ Error. You are not under a Git-repository directory tree.
    echo @ Exit.
    
    exit 1001
  fi;

  echo @ Initializing custom Git credential helper.
  # Disable other credential helpers.
  #helper =
  # Register our credential helper.
  #helper = /d/!00/git/credential-foo.sh passed parameters are here

else
  echo @ Providing a user password for Git>&2
  echo git_cred_user_password_variable_name is $git_cred_user_password_variable_name>&2
  echo ${!git_cred_user_password_variable_name}
fi




echo @@ $(basename "$BASH_SOURCE") end>&2


























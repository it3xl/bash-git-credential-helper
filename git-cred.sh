set -euf +x -o pipefail

## Install
#
# 1. Define credential environment variables that are suffixed with a real remote name from your Git-repository.
#$ git_cred_username_<remote-name>=some-login
#$ git_cred_password_<remote-name>=some-password
#
# 2. Register behaviour by calling
#$ source <path-to>/git-cred.sh  <remote-name>  init

## Usage
#
# Do not relocate this file after the install (otherwise reinstall it).
#
# Provide environment variables before any remote usage of your Git-repository (fetch, push, pull)
#$ git_cred_username_<remote-name>=some-login
#$ git_cred_password_<remote-name>=some-password

## How it works
#
# Git will call git-cred.sh automatically as it will become properly configured as a credential helper for your Git-remote.
# Just provide the above environment variables before any remote usage of your Git-repository (fetch, push, pull).

echo @@ $(basename "$BASH_SOURCE") start>&2

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

remote=${1-}
[[ -z "$remote" ]] && {
  echo @ Error. Exit. First parameter of a Git remote name is not provided.>&2
  exit 1
}

login_var_name=git_cred_username_$remote
[[ -z "${!login_var_name:+x}" ]] && {
  echo @ Error. Exit. There is no data in $login_var_name env-variable.>&2
  exit 1
}

password_var_name=git_cred_password_$remote
[[ -z "${!password_var_name+x}" ]] && {
  echo @ Error. Exit. There is no data in $password_var_name env-variable.>&2
  exit 1
}

action=${2-}

if [[ "$action" = "init" ]]; then

  is_inside_git_work_tree=1;
  git rev-parse --is-inside-work-tree > /dev/null 2>&1  ||  is_inside_git_work_tree=0
  if (( $is_inside_git_work_tree != 1 )); then
    echo @ Error. Exit. This script is run not inside a Git-repository directory tree.>&2
    exit 1
  fi;

  echo @ Initializing of git-cred custom Git credential helper.>&2
  git remote get-url $remote || {
    echo @ Error. Exit. There is no $remote remot in your Git-repository.>&2
    exit 1
  }
  
  repo_url=$(git remote get-url $remote)

  # Disable other credential helpers.
  git config credential.helper ''
  git config credential.${repo_url}.helper ''
  # Register our credential helper.
  git config --add credential.${repo_url}.helper \'"$BASH_SOURCE\'  $remote"

else
  echo @ Providing credentials for $remote Git remote>&2

  echo username=${!login_var_name}
  echo password=${!password_var_name}
fi




echo @@ $(basename "$BASH_SOURCE") end>&2




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
# bash var check: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
# bash var check: https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty/
# bash dynamic var: https://askubuntu.com/questions/926450/how-do-i-assign-a-variable-in-bash-whose-name-is-expanded-from-another-varia

















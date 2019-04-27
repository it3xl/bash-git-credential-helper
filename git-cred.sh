set -euf +x -o pipefail

#echo @@ $(basename "$BASH_SOURCE") start>&2

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


env_action_init=init
env_action_init_no_remote=init-for-url
env_action_get=get
env_action_help=help

env_exit_code=0



action=${1-}
remote=${2-}
# Let's grab a Git's API action. It's always sent as the last parameter.
git_action=${@:$#}




function under_git(){
  local is_inside_git_work_tree=1;
  
  git rev-parse --is-inside-work-tree > /dev/null 2>&1  ||  is_inside_git_work_tree=0
  
  if (( $is_inside_git_work_tree != 1 )); then
    echo @ Error. This script is run not inside a Git-repository directory tree.>&2
    
    return 1
  fi;
}

function set_login_var_name() {
  login_var_name=git_cred_username_$remote
  [[ -z "${!login_var_name:+x}" ]] && {
    echo @ Error. There is no data in $login_var_name env-variable.>&2
    
    return 1
  }
}

function set_login_var_name_for_no_remote() {
  login_var_name=git_cred_username
  [[ -z "${!login_var_name:+x}" ]] && {
    echo @ Error. There is no data in $login_var_name env-variable.>&2
    
    return 1
  }
}

function set_password_var_name() {
  password_var_name=git_cred_password_$remote
  [[ -z "${!password_var_name+x}" ]] && {
    echo @ Error. There is no data in $password_var_name env-variable.>&2

    return 1
  }
}

function set_password_var_name_for_no_remote() {
  password_var_name=git_cred_password
  [[ -z "${!password_var_name+x}" ]] && {
    echo @ Error. There is no data in $password_var_name env-variable.>&2

    return 1
  }
}

function check_remote() {
  [[ -z "$remote" ]] && {
    echo @ Error. First parameter of a Git remote name is not provided.>&2
    
    return 1
  }
}

function set_remote_url() {
  git remote get-url $remote > /dev/null  ||  {
    echo @ Error. There is no $remote remot in your Git-repository.>&2

    return 1
  }

  remote_url=$(git remote get-url $remote)
}

function set_remote_url_for_no_remote() {
  remote_url=$remote
}


function disable_other_git_helpers() {
  git config credential.helper ''
  git config credential.${remote_url}.helper ''
}

function register_git_helper() {
  git config --add credential.${remote_url}.helper \'"$BASH_SOURCE\'  get  $remote"
}

function register_git_helper_for_no_remote() {
  git config --add credential.${remote_url}.helper \'"$BASH_SOURCE\'  get"
}

function fail() {
  GIT_CRED_DO_NOT_EXIT
}


if [[ -z "$action" ]]; then
  
  echo bash Git Credential Helper>&2
  echo For help type>&2
  echo ''>&2
  echo source $(basename "$BASH_SOURCE") ' '$env_action_help>&2
  
elif [[ "$action" = "$env_action_init" ]]; then
  
  echo @ Initializing of git-cred custom Git credential helper.>&2
  
  under_git \
  && set_login_var_name \
  && set_password_var_name \
  && check_remote \
  && set_remote_url \
  && disable_other_git_helpers \
  && register_git_helper
  || fail
  
elif [[ "$action" = "$env_action_init_no_remote" ]]; then
  
  echo @ Initializing of git-cred custom Git credential helper.>&2
  
  under_git \
  && set_login_var_name_for_no_remote \
  && set_password_var_name_for_no_remote \
  && check_remote \
  && set_remote_url_for_no_remote \
  && disable_other_git_helpers \
  && register_git_helper_for_no_remote \
  || fail
  
elif [[ "$action" = "$env_action_get" ]]; then

  [[ "$git_action" = "get" ]] && {
    echo @ Providing credentials for $remote Git remote>&2
    
    echo username=${!login_var_name}
    echo password=${!password_var_name}
    
    exit 0
  }

  # For the store and the erase Git API commands.
  echo Ignoring of Git action '"'$git_action'"'>&2
  
elif [[ "$action" = "help" ]]; then
  
  echo ''
  echo @ Installation.
  echo ''
  echo @ 1. Change the shell working directory to your local Git-repository.
  echo '$ cd  <path-to-your-local-Git-Repo>'
  echo ''
  echo @ 2. for a remote name.
  echo ''
  echo 2.1. Define credential environment variables that are suffixed
  echo ' with a real remote name from your local Git-repository.'
  echo '$ git_cred_username_<remote-name>=some-login'
  echo '$ git_cred_password_<remote-name>=some-password'
  echo ''
  echo 2.2. Register behaviour by calling
  echo '$ source <path-to>'/$(basename "$BASH_SOURCE")'  '$env_action_init'  <remote-name>'
  echo ''
  echo @ 3. for an URL '(your local Git-repo has no a registered remote name)'.
  echo ''
  echo 3.1. Define credential environment variables that are suffixed
  echo ' with a real remote name from your Git-repository.'
  echo '$ git_cred_username=some-login'
  echo '$ git_cred_password=some-password'
  echo ''
  echo 3.2. Register behaviour by calling
  echo '$ source <path-to>/'$(basename "$BASH_SOURCE")'  '$env_action_init_no_remote' <remote-Git-repo-url>'
  echo ''
  echo @ Usage
  echo 1. Do not relocate this file after the installation
  echo '   (otherwise repeat installation instructions).'
  echo 2. Provide the above described environment variables before any
  echo '   git fetch, push, pull. I.e. before remote Git operations.'
  echo 3. For use in Jenkins. Use Credentials Binding Plugin '(or others)'
  echo '   to obtain credentials and hide them from any logging.'
  echo ''
  echo @ How it works
  echo *. Git will call $(basename "$BASH_SOURCE") automatically as it will become
  echo '   properly configured as a credential helper for your Git-remote.'
  echo *. Just provide the above environment variables before any
  echo '   remote usage of your Git-repository (fetch, push, pull).'
  
fi




#echo @@ $(basename "$BASH_SOURCE") end>&2







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
# bash test: https://ss64.com/bash/test.html
# bash dynamic var: https://askubuntu.com/questions/926450/how-do-i-assign-a-variable-in-bash-whose-name-is-expanded-from-another-varia

















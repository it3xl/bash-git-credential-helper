set -euf +x -o pipefail

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

script_name=$(basename "$BASH_SOURCE")
#echo @@ $script_name start>&2

env_action_init_by_remote=init-by-remote
env_action_init_by_url=init-by-url
env_action_get_by_remote=get-by-remote
env_action_get_by_url=get-by-url
env_action_help=help


action=${1-}
url_key=${2-}
url_key_escaped=${url_key//-/_}
url_input=${3-}

# Let's grab a Git's API action. It's always sent as the last parameter.
#git_action=${@:$#}
# but in our case it is always third parameter.
git_action=${3-}

function echo_intro(){
  echo ''>&2
  echo '  bash Git Credential Helper - https://github.com/it3xl/bash-git-credential-helper'>&2
  echo ''>&2
  echo '  For help type'>&2
  echo ''>&2
  echo '  source '$script_name'  '$env_action_help>&2
}

function echo_installing(){
  echo @ Installing of $script_name as a Git credential helper.>&2
}

function under_git(){
  local is_inside_git_work_tree=1;
  
  git rev-parse --is-inside-work-tree > /dev/null 2>&1  ||  is_inside_git_work_tree=0
  
  if (( $is_inside_git_work_tree != 1 )); then
    echo @ Error. This script is run not inside a Git-repository directory tree.>&2
    
    return 1
  fi;
}

function has_url_key() {
  if [[ -z "$url_key" ]]; then
    echo @ Error. Remote-name or an URL key parameter is not provided. See '$ source '$script_name'  '$env_action_help.>&2
    
    return 1
  fi
}

function has_url_input() {
  if [[ -z "$url_input" ]]; then
    echo @ Error. Url parameter is not provided. See '$ source '$script_name'  '$env_action_help.>&2
    
    return 1
  fi
}

function set_login_var_name() {
  login_var_name=git_cred_username_$url_key_escaped
}

function check_has_login() {
  if [[ "${!login_var_name:-}" == "" ]]; then
    echo @ Error. There is no data in $login_var_name env-variable.>&2
    
    return 1
  fi
}

function set_password_var_name() {
  password_var_name=git_cred_password_$url_key_escaped
}

function check_has_password() {
  if [[ "${!password_var_name:-}" == "" ]]; then
    echo @ Error. There is no data in $login_var_name env-variable.>&2
    
    return 1
  fi
}

function set_remote_url() {
  git remote get-url $url_key > /dev/null  ||  {
    echo @ Error. There is no $url_key remote in your Git-repository.>&2

    return 1
  }

  remote_url=$(git remote get-url $url_key)
}

function set_remote_url_by_url() {
  remote_url=$url_input
}


function disable_other_git_helpers() {
  git config --local credential.helper ''
  #git config --local credential.${remote_url}.helper ''
}

function register_git_helper() {
  git config --local --remove-section credential.${remote_url} > /dev/null 2>&1 || true
  
  shell_snippet="!'${BASH_SOURCE}'  $env_action_get_by_remote  $url_key"
  git config --local --add credential.${remote_url}.helper  "$shell_snippet"
  
  echo '    'at "credential.${remote_url}.helper" as
  echo '    '$(git config --local --get-all credential.${remote_url}.helper)
}

function register_git_helper_by_url() {
  git config --local --remove-section credential.${remote_url} > /dev/null 2>&1 || true
  
  shell_snippet="!'${BASH_SOURCE}'  $env_action_get_by_url $url_key"
  git config --local --add credential.${remote_url}.helper  "$shell_snippet"
  
  echo '    'at "credential.${remote_url}.helper" as
  echo '    '$(git config --local --get-all credential.${remote_url}.helper)
}

function echo_providing(){
  echo @ $script_name provides credentials for Git ' (https://github.com/it3xl/bash-git-credential-helper)'>&2
}

function not_an_action(){
  [[ -z "$action" ]]
}

function not_a_git_action(){
  if [[ "$git_action" == "get" ]]; then
    return 1
  fi
  
  # For the store and the erase Git API commands.
  echo @ $script_name ignores Git action '"'$git_action'"  (https://github.com/it3xl/bash-git-credential-helper)'>&2
}

function output_credentials(){
  echo username=${!login_var_name}
  echo password=${!password_var_name}
}

function output_help(){
  echo ''
  echo @ Installation.
  echo ''
  echo 1. Change the shell working directory to your local Git-repository.
  echo ' $ cd  <path-to-your-local-Git-Repo>'
  echo ''
  echo 2. For a remote name.
  echo ''
  echo 2.1. Define credential environment variables that are suffixed with a real remote name from your local Git-repository.
  echo '    In this variable names you must replace any dash with an underscore in <remote-name>.'
  echo ' $ git_cred_username_<remote-name>=some-login'
  echo ' $ git_cred_password_<remote-name>=some-password'
  echo ''
  echo 2.2. Register behaviour by calling
  echo ' $ source <path-to>/'$script_name'  '$env_action_init_by_remote'  <remote-name>'
  echo ''
  echo 3. For a remote repo URL '(your local Git-repo has no a registered remote name)'.
  echo ''
  echo 3.1. Define credential environment variables with an arbitrary key '<any-chars>'.
  echo ' $ git_cred_username_<any-chars>=some-login'
  echo ' $ git_cred_password_<any-chars>=some-password'
  echo ''
  echo 3.2. Register behaviour by calling
  echo ' $ source <path-to>/'$script_name'  '$env_action_init_by_url'  <any-chars>  <remote-Git-repo-url>'
  echo ''
  echo @ Usage
  echo 1. Do not relocate this file after the installation
  echo '   (otherwise repeat installation instructions).'
  echo 2. Provide the credential environment variables once before a remote Git usage.
  echo '   git fetch, push, pull, etc.'
  echo 3. For use in Jenkins. Use Credentials Binding Plugin '(or others)'
  echo '   to obtain credentials and hide them from any logging.'
  echo ''
  echo @ Sample and Getting Started
  echo Call test.sh to create confugured example repositories
  echo ' $ ./test.sh'
  echo See the code in test.sh to get started.
  echo ''
  echo @ How it works
  echo *. Git will call $script_name automatically as it will become
  echo '   properly configured as a credential helper for your Git-remote.'
  echo *. Just provide the above environment variables before any
  echo '   remote usage of your Git-repository (fetch, push, pull).'
}

function fail() {
  if [[ "${GIT_CRED_DO_NOT_EXIT:+1}" == "1" ]]; then
    echo The exit is suppressed by GIT_CRED_DO_NOT_EXIT env var
    
    return
  fi
  
  exit 1001
}



not_an_action \
&& echo_intro

if [[ "$action" = "$env_action_init_by_remote" ]]; then
  echo_installing \
  && under_git \
  && has_url_key \
  && set_login_var_name \
  && check_has_login \
  && set_password_var_name \
  && check_has_password \
  && set_remote_url \
  && disable_other_git_helpers \
  && register_git_helper \
  || fail
elif [[ "$action" = "$env_action_init_by_url" ]]; then
  echo_installing \
  && under_git \
  && has_url_key \
  && has_url_input \
  && set_login_var_name \
  && check_has_login \
  && set_password_var_name \
  && check_has_password \
  && set_remote_url_by_url \
  && disable_other_git_helpers \
  && register_git_helper_by_url \
  || fail
elif [[ "$action" = "$env_action_get_by_remote" ]]; then
  not_a_git_action \
  || ( \
    echo_providing \
    && under_git \
    && has_url_key \
    && set_login_var_name \
    && check_has_login \
    && set_password_var_name \
    && check_has_password \
    && set_remote_url \
    && output_credentials
  ) \
  || fail
elif [[ "$action" = "$env_action_get_by_url" ]]; then
  not_a_git_action \
  || ( \
    echo_providing \
    && under_git \
    && has_url_key \
    && set_login_var_name \
    && check_has_login \
    && set_password_var_name \
    && check_has_password \
    && set_remote_url_by_url \
    && output_credentials \
  ) \
  || fail
elif [[ "$action" = "help" ]]; then
  output_help
fi


#echo @@ $script_name end>&2



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
# bash parameter substitution: https://www.tldp.org/LDP/abs/html/parameter-substitution.html
















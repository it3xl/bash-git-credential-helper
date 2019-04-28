# bash Git Credential Helper
File [git-cred.sh](https://github.com/it3xl/bash-git-credential-helper/blob/master/git-cred.sh) implements
* a custom Git Credential Helper that is, Git Credential Store.
* It catches user credentials from environment variables and puts them to Git as a custom Git Credential Helper.
* It supports spaces in paths
* Use Credentials Binding Plugin (or others) in Jenkins to obtain credentials and hide them from any logging.

### Prepare Environment

Use any \*nix or Window machine.  
Install Git  

#### Usage from Windows CMD

For a remote Git-repo URL

    bash "/c/Jenkins/bash git credentila helper/git-cred.sh"  init-by-rul  https:/example.com/my.repo.git

For a remote name

    bash "/c/Jenkins/Your bash git credentila helper/location/git-cred.sh"  init  origin

### Instructions

To get the latest instructions type in a bash shell

    source git-cred.sh  help
    
In a Windows shell type

    bash git-cred.sh  help

 **An output from this command**

@ Installation.

1\. Change the shell working directory to your local Git-repository.

    cd  <path-to-your-local-Git-Repo>

2\. for a remote name.

2\.1. Define credential environment variables that are suffixed with a real remote name from your local Git-repository.  
**In this variable names you must replace any dash with an underscore in \<remote-name\>.**

    git_cred_username_<remote-name>=some-login
    git_cred_password_<remote-name>=some-password

2.2. Register behaviour by calling

    source <path-to>/git-cred.sh  init  <remote-name>

3\. for an URL (your local Git-repo has no a registered remote name).

3\.1. Define credential environment variables that are suffixed with a real remote name from your Git-repository.

    git_cred_username=some-login
    git_cred_password=some-password

3\.2. Register behaviour by calling

    source <path-to>/git-cred.sh  init-by-url <remote-Git-repo-url>

@ Usage
1\. Do not relocate this file after the installation
   (otherwise repeat installation instructions).
2\. Provide the credential environment variables once before a remote Git usage.
   git fetch, push, pull, etc.
3\. For use in Jenkins. Use Credentials Binding Plugin (or others)
   to obtain credentials and hide them from any logging.

@ Sample and Getting Started
Call test.sh to create confugured example repositories

    ./test.sh

See the code in test.sh to get started.

@ How it works  
*. Git will call git-cred.sh automatically as it will become properly configured as a credential helper for your Git-remote.  
*. Just provide the above environment variables before any remote usage of your Git-repository (fetch, push, pull).

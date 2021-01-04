# bash Git Credential Helper

### Where I'm using it

* Build-machines to run jobs under differenc accounts.
* Running scripts under different accounts.
* Running from cron(s), at, PowerShell Scheduled Tasks and Jobs.

### Main notes

File [git-cred.sh](https://github.com/it3xl/bash-git-credential-helper/blob/master/git-cred.sh) implements
* a custom Git Credential Helper that is some Git Credential Store.
* It catches user credentials from environment variables and puts them to Git as a custom Git Credential Helper.
* It supports spaces in paths
* Use Credentials Binding Plugin (or others) in Jenkins to obtain credentials and hide them from any logging.

The latest tested Git version is 2.30.0 

### Prepare Environment

Use any \*nix or Window machine.  
Install Git  

#### Usage from Windows CMD

For a remote Git-repo URL

    bash "/c/Jenkins/bash git credentila helper/git-cred.sh"  init  arbitrary_word  https:/example.com/my.repo.git

For a remote name (you can use any existing remote name)

    bash "/c/Jenkins/Your bash git credentila helper/location/git-cred.sh"  init  origin

### Instructions

To see help run in bash

    source git-cred.sh  help
    
Or in Windows CMD

    bash git-cred.sh  help

@ Installation.

1\. Change the shell working directory to your local Git-repository root.

    cd  <path-to-your-local-Git-Repo-root>

2\. For a remote name.

2\.1. Define credential environment variables as below that are suffixed with a real remote name from your local Git-repository.  
**You must replace any dashes with underscores in \<remote_name\> in these variable names.**

    git_cred_username_<remote_name>=some-login
    git_cred_password_<remote_name>=some-password

Some Continues Integration tools (Jenkins) fill them automatically

2.2. Register git-cred.sh as the Git credentila helper by calling

    source <path-to>/git-cred.sh  init  <remote_name>

3\. For a remote repo URL (your local Git-repo has no a registered remote name).

3\.1. Define credential environment variables with an arbitrary word \<some_chars\>.

    git_cred_username_<some_chars>=another-login
    git_cred_password_<some_chars>=another-password

3\.2. Register git-cred.sh as the Git credentila helper by calling

    source <path-to>/git-cred.sh  init  arbitrary_word <remote-Git-repo-url>

@ Usage  
1\. Do not relocate this file after the installation (otherwise repeat the installation instructions).  
2\. Provide the credential environment variables once before any remote Git usage (git fetch, push, pull, etc.).  
3\. For use in Jenkins. Use Credentials Binding Plugin (or others) to obtain credentials and hide them from any logging.

@ Sample and Getting Started  
Call [test.sh](https://github.com/it3xl/bash-git-credential-helper/blob/master/test/test.sh) to create configured example repositories

    $  ./test/test.sh

See its code to get started.

**[git-repo-sync](https://github.com/it3xl/git-repo-sync)** project is integrated with **git-cred** and you can dig out some usage from there, too.

@ How it works  
*. Git will call git-cred.sh automatically as it will become properly configured as a Git credential helper.  
*. Just provide the above environment variables before any remote usage of your Git-repository (fetch, push, pull, etc.).

## Warning for users of Git 2.26 version.

Git of 2.26 version has a bug that affects the **bash Git Credential Helper**.<br/>
I [reported this bug](https://www.spinics.net/lists/git/msg379664.html) and it is fixed. Just use the Git of another version.<br/>
Probably, 2.25 also may have some troubles. But 2.24 works rigth.

If you forsed to use 2.26 Git version then use the following workaround.<br/>
The **bash Git Credential Helper** will stop to be invoked by the Git in case if your repository URL has an additional folder part(s).  
For example /my-proj/ in https://exaple.com/my-proj/my-repo.git

As workaround you can cut your URL to a root view in the Git config file.  
For example, you have to use https://exaple.com/ instead of https://exaple.com/my-proj/my-repo.git

I.e. replace 

[credential "https://git.exaple.com/my-proj/my-repo.git"]
    helper = !'/c/some-path/bash-git-credential-helper/git-cred.sh' provide  repo_b

to

[credential "https://git.exaple.com/"]
    helper = !'/c/some-path/bash-git-credential-helper/git-cred.sh' provide  repo_b

# bash Git Credential Helper
File git-cred.sh implements
* a custom Git Credential Helper that is, Git Credential Store.
* a GIT_ASKPASS logic.
* using of credential information from enviroment variables
* integrating with Jenkins.

It is an all-in-one approach.

It converts user credentials from environment variables and puts them to Git as a custom Git Credential Helper or as a GIT_ASKPASS registered script.

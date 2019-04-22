
user_name_var=some-login
user_password_var=some-password

echo ''
echo Testing of empty Git-repo URL
source git-cred.sh  init  user_name_var  user_password_var

echo ''
echo error is $?

echo ''
echo Testing with a Git-repo URL
source git-cred.sh  init  user_name_var  user_password_var  https://my.git.repo

echo ''
echo error is $?

echo ''
echo Testing GIT_ASKPASS  '(for Git)'
source $GIT_ASKPASS

echo ''
echo error is $?

echo ''
echo Testing GIT_ASKPASS  Username  '(for Jenkins)'
source $GIT_ASKPASS  Username

echo ''
echo error is $?

echo ''
echo Testing GIT_ASKPASS  Password  '(for Jenkins)'
source $GIT_ASKPASS  Password

echo ''
echo error is $?


echo ''
echo sleep...
sleep 45s
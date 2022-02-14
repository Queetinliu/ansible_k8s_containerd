#/bin/bash
set -x
ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa <<< ""$'\n'"y" #始终覆盖以前生成的密钥
while read line;
   do
   ip=$(echo $line|awk '{print $1}')
   password=$(echo $line|awk '{print $2}')
   SSHPASS=$password sshpass -e ssh-copy-id -o StrictHostKeyChecking=no root@$ip
   done  < $PWD/hosts
rm -f $PWD/hosts

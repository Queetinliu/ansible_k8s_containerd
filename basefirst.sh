#!/bin/bash
set -uxo pipefail
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
result=$(rpm -qa|grep ansible)
ping -c 1 -q baidu.com >& /dev/null
if [[ $? != 0 ]];then
set -e
rm -f /etc/yum.repos.d/*.repo
cd $SCRIPTPATH/baserpms
  if [[ $result == "" ]];then
  yum install -y *  # install httpd vim sshpass ansible createrepo ntfs-g3 nfs-utils pciutils
  fi
cp $SCRIPTPATH/globalrpms/* /var/www/html  
else
set -e
 if [[ $result == "" ]];then
   yum install -y epel-release
   yum install -y httpd vim sshpass ansible createrepo nfs-utils ntfs-3g ntfsprogs pciutils
 fi
cp $SCRIPTPATH/kernelrpms/* /var/www/html
fi
set -e
sed -i 's/Listen 80/Listen 18080/' /etc/httpd/conf/httpd.conf

sed -i  -r -e "s@#inventory      = /etc/ansible/hosts@inventory      = $SCRIPTPATH/ansible_k8s_flannel/hosts@"  -e "s@#pipelining = False@pipelining = True@" -e "s@#host_key_checking = False@host_key_checking = False@" -e "s@#callback_whitelist = timer, mail@callback_whitelist = profile_tasks@" -e "s@#control_path_dir = ~/.ansible/cp@control_path_dir = ~/.ansible/cp@" -e "s@# control_path = %(directory)s/%%h-%%r@control_path = %(directory)s/%%h-%%r@" /etc/ansible/ansible.cfg

if [ -d /var/www/html/repodata ];then
rm -rf /var/www/html/repodata
fi

createrepo /var/www/html
selinux=$(getenforce)
if [[ $selinux != "Disabled" ]];then
setenforce 0
fi
systemctl restart httpd
systemctl enable httpd


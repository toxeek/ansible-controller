#!/bin/bash

# bootstrap for ansible on GCE.
# it seems that ansible pem_file is broken on Ansible 2
# we will install latest ansible from github not Yum, and also libcloud from github

[ "$UID" -ne "0" ] && echo "you are not root." >&2 && exit 1

# we redirect stderr and stdout to log files
exec 2> >(tee "../err_log") 
exec > >(tee "../out_log")

YUM=$(which yum)

echo "[+] update yum .."
$YUM -y update yum >/dev/null  
echo "[+] update and upgrade local packages .."
$YUM -y update >/dev/null && $YUM -y upgrade 
echo "[+] install epel-release .."
$YUM -y install epel-release >/dev/null
echo "[+] install python and dependencies .."
$YUM -y install python python-devel python-pip curl git-core gcc python-libcloud
echo "[+] install apache-libcloud dependency .."
$(which pip) install paramiko PyYAML jinja2 httplib2
echo "[+] install apache-libcloud from github .."
$YUM remove ansible apache-libcloud 
cd /usr/local/src
$(which git) clone https://github.com/apache/libcloud
cd libcloud
$(which python) setup.py install
echo "[+] installing ansible from github .."
cd /usr/local/src
$(which git) clone "git://github.com/ansible/ansible.git"
cd ansible
make install
echo "[+] install GCE SDK .."
$(which curl) "https://sdk.cloud.google.com" | bash
exec -l $SHELL
$(which gcloud) init

# download ansible galaxy roles
# ntp role
$(which ansible-galaxy) install geerlingguy.ntp
 
echo "[+] now cofigure git config --global user.name my_name && git config user.email my@email" 
echo "[+] log out then in, or run:  source ~/.bashrc"

echo "[+] Done." 

exit 0


#!/bin/bash

# bootstrap for ansible on GCE.
# it seems that ansible pem_file is broken on Ansible 2
# we will install latest ansible from github not Yum, and also libcloud from github

# prerequsites - git, better do a yum update && yum upgrade first too

[ "$UID" -ne "0" ] && echo "you are not root." >&2 && exit 1

# we redirect stderr and stdout to log files
exec 2> >(tee "../err_log") 
exec > >(tee "../out_log")

YUM=$(which yum)

echo "[+] install epel-release .."
$YUM -y install epel-release >/dev/null
echo "[+] install python and dependencies .."
$YUM -y install python python-devel python-pip asciidoc git rpm-build python2-devel curl gcc
echo "[+] install apache-libcloud dependency .."
$(which pip) install paramiko PyYAML jinja2 httplib2
echo "[+] install apache-libcloud from github .."
$YUM -y remove ansible apache-libcloud 
cd /usr/local/src
$(which git) clone https://github.com/apache/libcloud
cd libcloud
$(which python) setup.py install
echo "[+] installing ansible from github .."
cd /usr/local/src
$(which git) clone git://github.com/ansible/ansible.git --recursive
cd /usr/local/src/ansible
$(which make) "rpm"
$YUM localinstall -y "rpm-build"/ansible-*[0-9].noarch.rpm
# $(which pip) install git+https://github.com/ansible/ansible.git@v2_final#egg=ansible
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


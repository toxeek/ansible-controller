#!/bin/bash

# bootstrap for ansible on GCE.
# it seems that ansible pem_file is broken on Ansible 2
# we will install latest ansible from github not Yum, and also libcloud from github

# prerequisites - git, better do a yum update && yum upgrade first too

[ "$UID" -ne "0" ] && echo "you are not root." >&2 && exit 1

# we redirect stderr and stdout to log files
exec 2> >(tee "../err_log") 
exec > >(tee "../out_log")

YUM=$(which yum)

echo "[+] install epel-release .."
$YUM -y install epel-release >/dev/null
echo "[+] install python and dependencies .."
$YUM -y install python python-devel python-pip asciidoc git rpm-build python2-devel curl wget gcc
echo "[+] install apache-libcloud dependency .."
$(which pip) install paramiko PyYAML jinja2 httplib2
echo "[+] install apache-libcloud from github .."
$YUM -y remove ansible apache-libcloud 
$(which pip) install pip --upgrade
$(which pip) install apache-libcloud --upgrade
echo "[+] installing ansible from github .."
cd /usr/local/src
$(which git) clone git://github.com/ansible/ansible.git --recursive
cd /usr/local/src/ansible
$(which make) "rpm"
$YUM localinstall -y "rpm-build"/ansible-*[0-9].noarch.rpm
# we install aws-cli
$(which pip) install awscli
$(which pip) install --upgrade awscli

echo "[+] DOne."

exit 0


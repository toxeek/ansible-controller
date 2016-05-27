#!/bin/bash

# bootstrap for ansible on GCE.
# it seems that ansible pem_file is broken on Ansible 2
# we will install latest ansible from github not Yum, and also libcloud from github

# prerequisites - git, better do a yum update && yum upgrade first too

[ "$UID" -ne "0" ] && echo "you are not root." >&2 && exit 1

# we redirect stderr and stdout to log files
exec 2> >(tee "../err_log") 
exec > >(tee "../out_log")

APT=$(which apt)

echo "[+] install python and dependencies .."
$APT -y install python python-devel python-pip asciidoc git curl wget gcc python-yaml sshpass
echo "[+] install apache-libcloud dependency .."
$(which pip) install paramiko PyYAML jinja2 httplib2
$(which pip) install pip --upgrade
echo "[+] installing ansible from github .."
cd /usr/local/src
$(which git) clone git://github.com/ansible/ansible.git --recursive
cd /usr/local/src/ansible
echo "[+] we checkout the latest stable branch .."
LATEST_STABLE="$(git branch -a | grep stable | awk -F"/" '{print $NF}' | sort -u | tail -1)"
$(which git) checkout $LATEST_STABLE
echo "[+] making the deb file for dpkg .."
$(which make) "deb"
echo "[+] installing the deb file .."
find deb-build -name "ansible*deb" -exec dpkg -i '{}' \;
# we set the owner of ~/.ansible to current user
me="$(who am i | awk '{print $1}')"
chown -R $me ~/.ansible
# we install aws-cli
$(which pip) install awscli
$(which pip) install --upgrade awscli

echo "[+] DOne."

exit 0


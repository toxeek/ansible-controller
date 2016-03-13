#!/bin/bash

# bootstrap for ansible on GCE.

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
$YUM -y install python python-devel python-pip curl git-core gcc 
echo "[+] install apache-libcloud dependency .."
$(which pip) install paramiko PyYAML jinja2 httplib2 apache-libcloud
echo "[+] install GCE SDK .."
$(which curl) "https://sdk.cloud.google.com" | bash
exec -l $SHELL
$(which gcloud) init


echo "[+] Done." && exit 0


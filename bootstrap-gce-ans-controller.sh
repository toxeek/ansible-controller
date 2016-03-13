#!/bin/bash

# @ Yospace - All rights reserved.

# bootstrap for ansible on GCE.

[ "$UID" -ne "0" ] && echo "you are not root." >&2 && exit 1

# we redirect stderr and stdout to log files
exec 2> >(tee "../err_log") 
exec > >(tee "../out_log")

YUM=$(which yum)

echo "[+] update yum .."
$YUM -y update yum >/dev/null  
echo "[+] update and upgrade local packages .."
$YUM -y update >/dev/null && $YUM -y upgrade >/dev/null
echo "[+] install epel-release .."
$YUM -y install epel-release >/dev/null
echo "[+] install python and dependencies .."
$YUM -y install python python-devel python-pip curl >/dev/null
echo "[+] install apache-libcloud dependency .."
$(which pip) -y install apache-libcloud
echo "[+] install GCE gcloud .."
$(which curl) "https://sdk.cloud.google.com" | bash
exec -l $SHELL
$(which gcloud) init


echo "[+] Done." && exit 0


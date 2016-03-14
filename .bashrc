# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# The next line updates PATH for the Google Cloud SDK.
source '/root/google-cloud-sdk/path.bash.inc'

# The next line enables shell command completion for gcloud.
source '/root/google-cloud-sdk/completion.bash.inc'

ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOST_KEY_CHECKING

eval $(ssh-agent)

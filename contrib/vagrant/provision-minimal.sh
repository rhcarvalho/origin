#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

sed -i s/^Defaults.*requiretty/\#Defaults\ requiretty/g /etc/sudoers

# patch incompatible with fail-over DNS setup
SCRIPT='/etc/NetworkManager/dispatcher.d/fix-slow-dns'
if [[ -f "${SCRIPT}" ]]; then
    echo "Removing ${SCRIPT}..."
    rm "${SCRIPT}"
    sed -i -e '/^options.*$/d' /etc/resolv.conf
fi
unset SCRIPT

if [ -f /usr/bin/generate_openshift_service ]
then
  sudo /usr/bin/generate_openshift_service
fi

# Ensure system is up-to-date.
sudo dnf upgrade -y

# Install some useful packages.
sudo dnf install -y bash-completion nc tree

# Clean temp dnf files.
sudo dnf clean all

# Update /etc/profile.d/openshift.sh
sudo tee -a /etc/profile.d/openshift.sh > /dev/null <<-EOF

	# Add s2i to the PATH.
	export PATH=/data/src/github.com/openshift/source-to-image/_output/local/bin/linux/amd64:\$PATH

	# Easily cd to any openshift project.
	export CDPATH=.:/data/src/github.com/openshift

	# Enable completion for openshift binaries.
	for bin in oc oadm openshift; do
	  source <(\$bin completion bash)
	done

	# Save Bash history outside of the VM, so that it is preserved on destroy -> up
	ln -sf /data/src/github.com/openshift/origin/.vagrant/bash_history ~/.bash_history
EOF

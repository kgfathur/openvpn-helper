#!/bin/bash

work_dir=$(pwd)

if [[ "$EUID" -ne 0 ]]; then
	echo "This installer needs to be run with superuser privileges."
	exit
fi

install_dir="/opt/openvpn-setup"
mkdir $install_dir
cp $work_dir/openvpn-setup $install_dir/
chmod u+x $install_dir/openvpn-setup
update-alternatives --install /usr/bin/openvpn-setup openvpn-setup /opt/openvpn-setup/openvpn-setup 0

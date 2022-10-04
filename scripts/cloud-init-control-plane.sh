#!/bin/bash

set -e

dnf -y install oracle-olcne-release-el8
dnf config-manager --enable ol8_olcne15 ol8_addons ol8_baseos_latest ol8_appstream ol8_UEKR6
dnf config-manager --disable ol8_olcne12 ol8_olcne13 ol8_olcne14 ol8_developer
# dnf list --installed chrony
# systemctl enable --now chronyd
swapoff -a
sed -i '/swap/ s/^#*/#/' /etc/fstab

firewall-offline-cmd --add-port=8091/tcp
firewall-offline-cmd --zone=trusted --add-interface=cni0
firewall-offline-cmd --add-port=8090/tcp
firewall-offline-cmd --add-port=10250/tcp
firewall-offline-cmd --add-port=10255/tcp
firewall-offline-cmd --add-port=8472/udp
firewall-offline-cmd --add-port=6443/tcp
firewall-offline-cmd --add-port=10251/tcp
firewall-offline-cmd --add-port=10252/tcp
firewall-offline-cmd --add-port=2379/tcp
firewall-offline-cmd --add-port=2380/tcp
systemctl restart dbus
systemctl enable --now firewalld

modprobe br_netfilter
sh -c 'echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf'

dnf -y install olcnectl olcne-api-server olcne-utils
systemctl enable olcne-api-server.service

dnf -y install olcne-agent olcne-utils
systemctl enable olcne-agent.service
#!/bin/bash

set -e

dnf -y install oracle-olcne-release-el8
dnf config-manager --enable ol8_olcne15 ol8_addons ol8_baseos_latest ol8_appstream ol8_UEKR6
dnf config-manager --disable ol8_olcne12 ol8_olcne13 ol8_olcne14 ol8_developer
# dnf list --installed chrony
# systemctl enable --now chronyd
swapoff -a
sed -i '/swap/ s/^#*/#/' /etc/fstab

dnf -y install olcnectl olcne-api-server olcne-utils
systemctl enable olcne-api-server.service

dnf -y install olcne-agent olcne-utils
systemctl enable olcne-agent.service
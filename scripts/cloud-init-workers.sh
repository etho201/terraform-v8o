#!/bin/bash

set -e

sudo dnf -y install oracle-olcne-release-el8
sudo dnf config-manager --enable ol8_olcne15 ol8_addons ol8_baseos_latest ol8_appstream ol8_UEKR6
sudo dnf config-manager --disable ol8_olcne12 ol8_olcne13 ol8_olcne14 ol8_developer
# sudo dnf list --installed chrony
# sudo systemctl enable --now chronyd
sudo swapoff -a
sudo sed -i '/swap/ s/^#*/#/' /etc/fstab

sudo dnf -y install olcne-agent olcne-utils
sudo systemctl enable olcne-agent.service


#!/bin/bash

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

sudo apt-get update && sudo apt-get install -y chrony
sudo systemctl enable chrony
sudo systemctl start chrony

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=" --write-kubeconfig-mode=644 --flannel-iface=eth1 -- " sh -

kubectl apply -f confs/

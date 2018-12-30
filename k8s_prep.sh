#!/bin/sh

# This installs the base instructions up to the point of joining / creating a cluster
# Based off of https://gist.github.com/alexellis/fdbc90de7691a1b9edb545c17da2d975#gistcomment-2228114

echo Adding " cgroup_enable=cpuset cgroup_memory=1" to /boot/cmdline.txt

sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1"
echo $orig | sudo tee /boot/cmdline.txt

curl -s https://download.docker.com/linux/raspbian/gpg | sudo apt-key add -
echo "deb [arch=armhf] https://download.docker.com/linux/raspbian stretch edge" | sudo tee /etc/apt/sources.list.d/socker.list
apt-get update -q
apt-get install -y docker-ce=18.06.0~ce~3-0~raspbian --allow-downgrades
echo "docker-ce hold" | sudo dpkg --set-selections
usermod pi -aG docker

dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -q
apt-get install -y kubeadm=1.13.1-00 kubectl=1.13.1-00 kubelet=1.13.1-00

echo reboot....

reboot

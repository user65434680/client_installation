sudo apt update -y
sudo apt upgrade -y
sudo systemctl disable apparmor --now

sudo apt install unbound -y
sudo systemctl enable unbound
sudo apt install openssh-server -y
sudo systemctl enable openssh-server

sudo apt install policycoreutils selinux-utils selinux-basics
sudo selinux-activate
# in the future add sudo selinux-config-enforcing
sudo bash network.sh

sudo reboot

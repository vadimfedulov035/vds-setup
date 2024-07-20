#!/bin/bash

user="veotri"
name="Vadim"
email="vadimfedulov035@gmail.com"

set_ufw() {
	echo "UFW setup..."
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow OpenSSH
        ufw allow http
        ufw allow https
}

set_swap() {
	echo "Swap setup..."
        if [ $(free -h | grep "Swap" | awk '{print $2}') != "2.0Gi" ]; then
                swapoff /swap.img
                rm /swap.img
                fallocate -l 2G /swap.img
                chmod 600 /swap.img
                mkswap /swap.img
                swapon /swap.img
                sysctl vm.swappiness=200
        fi
	d="vm\.swappiness=[0-9]*"  # default value
	setting="vm\.swappiness=200"
	settings="/etc/sysctl.conf"
	grep -q "^$setting" "$settings" || sed -i "s/$d/$setting/g" "$settings"
	sysctl -p
}

set_journald() {
	echo "Jouarnald setup..."
        setting="SystemMaxUse=100M"
        settings="/etc/systemd/journald.conf"
        grep -q "^$setting" "$settings" || echo "$setting" >> "$settings"
}

set_git() {
	echo "Git setup..."
	git config --global init.defaultBranch main
	git config --global user.name $name
	git config --global user.email $email
}

set_python() {
	echo "Python setup..."
	pip install pyTelegramBotAPI --break-system-packages 
}

set_golang() {
	echo "Golang setup..."
	# bin setup
	website="https://go.dev/dl/?mode=json"
	exp="go.*.linux-amd64.tar.gz"
	version=$(curl "$website" | grep -o "$exp" | head -n 1 | tr -d '\r\n')
	echo $version
	wget "https://go.dev/dl/$version" && rm -rf /usr/local/go
	tar -C /usr/local -xzf "$version" && rm "$version"
	# path setup
	PATH=$PATH:/usr/local/go/bin 
	settings="/root/.bashrc"
	setting="PATH=\$PATH:/usr/local/go/bin"
	grep -q "^$setting" "$settings" || echo "$setting" >> "$settings" 
}

set_vim() {
	echo "Vim setup..."
	settings="/root/.vimrc"
	setting_arr=("set colorcolumn=80" "match ErrorMsg '\%>80v.\+'")
	for setting in "${setting_arr[@]}"; do
		if ! grep -q "^$setting" "$settings"; then
			echo "$setting" >> "$settings" 
		fi
	done
}

set_user() {
	echo "User setup..."
	adduser $user
	usermod -aG sudo $user
	ssh-keygen -t ed25519
	positive="PermitRootLogin yes"
	negative="PermitRootLogin no"
	sed -i "s/$positive/$negative/g" /etc/ssh/sshd_config
	systemctl restart sshd
}

install_deps() {
	apt update && apt upgrade -y
	apt install ufw cron git wget python3-pip vim tmux htop figlet -y 
}

install_deps

set_ufw
set_swap
set_journald

set_git
set_python
set_golang

set_vim

set_user

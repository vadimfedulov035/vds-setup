#!/bin/bash

USER="veotri"
NAME="Vadim"
EMAIL="vadimfedulov035@gmail.com"

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
                sysctl vm.swappiness=100
        fi
	d="vm\.swappiness=[0-9]*"
	setting="vm\.swappiness=100"
	settings="/etc/sysctl.conf"
	grep -q "^$setting" "$settings" || sed -i "s/$d/$setting/g" "$settings"
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
	git config --global user.name $NAME
	git config --global user.email $EMAIL
    V_LINK="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
    VERSION=$(curl -s $V_LINK | grep -Po '"tag_name": "v\K[^"]*')
    ARC="lazygit_${VERSION}_Linux_x86_64.tar.gz"
    ARC_PATH="releases/latest/download/$ARC" 
    LINK="https://github.com/jesseduffield/lazygit/$ARC_PATH"
    curl -Lo lazygit.tar.gz $LINK
    tar xf lazygit.tar.gz lazygit
    install lazygit /usr/local/bin
    rm -f lazygit*
}

set_python() {
	echo "Python setup..."
    apt install python3-pip -y
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
    curl -sL install-node.vercel.app/lts | bash
	settings="/root/.vimrc"
    setting_arr=(
        "set expandtab"
        "set tabstop=4"
        "set shiftwidth=4"
        "set smarttab"
        "set smartindent"
        ""
        "set number"
        "set cursorline"
        "set colorcolumn=80"
        "match ErrorMsg '\%>80v.\+'"
        ""
        "call plug#begin()"
        "Plug 'vim-airline/vim-airline'"
        "Plug 'neoclide/coc.nvim', {'branch': 'release'}"
        "Plug 'preservim/nerdtree'"
        "Plug 'nordtheme/vim'"
        "call plug#end()"
        ""
        "colorscheme nord"
    )
    echo "" > $settings
	for setting in "${setting_arr[@]}"; do
			echo "$setting" >> "$settings"
	done
	echo "Don't forget to :PlugInstall in Vim"
}

set_user() {
	echo "User setup..."
	adduser $USER
	usermod -aG sudo $USER
	ssh-keygen -t ed25519
    positive="PermitRootLogin yes"
	negative="PermitRootLogin no"
	sed -i "s/$positive/$negative/g" /etc/ssh/sshd_config
	systemctl restart sshd
}

install_deps() {
    apt update && apt upgrade -y
    apt install ufw cron git lazygit wget -y
    apt install vim tmux htop figlet -y
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

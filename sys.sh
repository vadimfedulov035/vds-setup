#!/bin/bash

set_ufw() {
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow OpenSSH
        ufw allow http
        ufw allow https
}

set_cron() {
        crontab -l > cron
	local cron_cmds=("$@")
        for cron_cmd in "${cron_cmds[@]}"; do
                if ! grep -F -q "$cron_cmd" cron; then
                    echo "$cron_cmd" >> cron
                fi
        done
        crontab cron
        rm cron
}

set_swap() {
        if [ $(free -h | grep "Swap" | awk '{print $2}') != "2.0Gi" ]; then
                swapoff /swap.img
                rm /swap.img
                fallocate -l 2G /swap.img
                chmod 600 /swap.img
                mkswap /swap.img
                swapon /swap.img
                sysctl vm.swappiness=200
        fi
	default="vm\.swappiness=[0-9]*"
	setting="vm\.swappiness=200"
	settings="/etc/sysctl.conf"
	grep -q "^$setting" "$settings" || sed -i "s/$default/$setting/g" "$settings"
}

set_journald() {
        setting="SystemMaxUse=100M"
        settings="/etc/systemd/journald.conf"
        grep -q "^$setting" "$settings" || echo "$setting" >> "$settings"
}

set_vds() {
	apt update && apt install wget cron ufw figlet -y
	local cron_cmds=("$@")
	if [ ! -z "${cron_cmds}" ] && [ "${#cron_cmds[@]}" -gt 0 ]; then
		set_cron "${cron_cmds[@]}"
	fi
	set_ufw
	set_swap
	set_journald
}

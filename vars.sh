#!/bin/bash

get_webhost() {
        if [ -s "$WEBHOST_FILE" ]; then
                webhost=$(cat "$WEBHOST_FILE")
        else
                try=$(whiptail --inputbox "Type webhost:" 10 50 3>&1 1>&2 2>&3)
                if [[ -n "$try" ]]; then
                        echo "$try" > "$WEBHOST_FILE"
                        whiptail --msgbox "Webhost saved to file '$WEBHOST_FILE' for reuse" 10 50
                else
                        whiptail --msgbox "No webhost provided!" 10 50
                fi
		get_webhost
        fi
}

get_email() {
        if [ -s "$EMAIL_FILE" ]; then
                email=$(cat "$EMAIL_FILE")
        else
                try=$(whiptail --inputbox "Type email:" 10 50 3>&1 1>&2 2>&3)
                if [[ -n "$try" ]]; then
                        echo "$try" > "$EMAIL_FILE"
                        whiptail --msgbox "Email saved to file '$EMAIL_FILE' for reuse" 10 50
                else
                        whiptail --msgbox "No email provided!" 10 50
                fi
		get_email
        fi
}

get_secret() {
        if [ -s "$SECRET_FILE" ]; then
                secret=$(cat "$SECRET_FILE")
        else
		first_try=$(whiptail --inputbox "Type secret (token):" 10 50 3>&1 1>&2 2>&3)
		second_try=$(whiptail --inputbox "Retype secret (token):" 10 50 3>&1 1>&2 2>&3)
                if [[ -n "$first_try" && "$first_try" == "$second_try" ]]; then
                        echo "$first_try" > "$SECRET_FILE"
			whiptail --msgbox "Secret (token) saved to file '$SECRET_FILE' for reuse" 10 50
                else
			whiptail --msgbox "Secret (token) values are not the same or nothing!" 10 50
                fi
		get_secret
        fi
}

# loop until confirmation
check() {
	if ! whiptail --yesno "$question" 10 50 3>&1 1>&2 2>&3; then
		rm -f "$WEBHOST_FILE" "$EMAIL_FILE" "$SECRET_FILE"
		get_vars "$1"
	fi
}

get_vars() {
        apt update && apt install whiptail -y
	question="Is everything correct?\n"
	[[ "$1" == *"webhost"* ]] && get_webhost && question+="Webhost: $webhost\n"
	[[ "$1" == *"email"* ]] && get_email && question+="Email: $email\n"
	[[ "$1" == *"secret"* ]] && get_secret && question+="Secret: $secret\n"
	check "$1"
}

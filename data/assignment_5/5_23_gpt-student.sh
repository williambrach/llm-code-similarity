
display_usage() {
	echo
	echo "Script Version 2.0"
	echo
	echo "Usage: $0 options"
	echo
	echo "Options:"
	echo " -h: Display this help message and exit"
	echo
	echo " -u: Show users with a login count above 10 by default"
	echo
	echo " -u <number>: Show users with a login count above <number>"
	echo
	echo " -l <log_file>: Define a log file for user login data. Defaults to 'login.2021'"
	echo
	echo "Example:"
	echo " $0 -l access.log -u 5"
	echo
}

parse_arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			-h)
				display_usage
				exit 0
				;;
			-u)
				shift
				login_threshold="$1"
				;;
			-l)
				shift
				user_log_file="$1"
				;;
			*)
				echo "Error: Unrecognized option '$1'" >&2
				exit 1
				;;
		esac
		shift
	done
}

check_inputs() {
	if [ -z "$login_threshold" ]; then
		login_threshold=10
	fi
	if ! [[ "$login_threshold" =~ ^[0-9]+$ ]]; then
		echo "Error: '$login_threshold' is not a valid number for -u option" >&2
		exit 1
	fi
	if [ -z "$user_log_file" ]; then
		user_log_file="login.2021"
	fi
	if [ ! -f "$user_log_file" ]; then
		echo "Error: File '$user_log_file' does not exist" >&2
		exit 1
	fi
}

evaluate_logins() {
	login_data=$(last -f "$user_log_file" | awk '$3 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { print $1, $3 }' | sort | uniq -c | sort -nr)
	while read -r entry; do
		username=$(echo "$entry" | awk '{print $2}')
		login_count=$(echo "$entry" | awk '{print $1}')
		if [ "$login_count" -gt "$login_threshold" ]; then
			echo "User: '$username' Logins: $login_count"
		fi
	done <<< "$login_data"
}

parse_arguments "$@"
check_inputs
evaluate_logins


show_help() {
	echo
	echo "Version of Script: 2.0"
	echo
	echo "How to use: $0 [options]"
	echo
	echo "Available options:"
	echo " -h: Show help information and exit"
	echo
	echo " -u: Display users with more than 10 logins by default"
	echo " -u <value>: Display users with more than <value> logins"
	echo
	echo " -l <file_path>: Specify a log file for user login data. Default is 'login.2021'"
	echo
	echo "Example usage:"
	echo " $0 -l user.log -u 20"
	echo
}

handle_args() {
	while [ $# -gt 0 ]; do
		case $1 in
			-h)
				show_help
				exit 0
				;;
			-u)
				shift
				min_logins="$1"
				;;
			-l)
				shift
				login_file="$1"
				;;
			*)
				echo "Error: Option '$1' not recognized" >&2
				exit 1
				;;
		esac
		shift
	done
}

validate_inputs() {
	if [ -z "$min_logins" ]; then
		min_logins=10
	fi
	if ! [[ "$min_logins" =~ ^[0-9]+$ ]]; then
		echo "Error: The value '$min_logins' for -u is not a valid number" >&2
		exit 1
	fi
	if [ -z "$login_file" ]; then
		login_file="login.2021"
	fi
	if [ ! -f "$login_file" ]; then
		echo "Error: The file '$login_file' cannot be found" >&2
		exit 1
	fi
}

process_logins() {
	login_info=$(last -f "$login_file" | awk '$3 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { print $1, $3 }' | sort | uniq -c | sort -nr)
	while read -r line; do
		user=$(echo "$line" | awk '{print $2}')
		count=$(echo "$line" | awk '{print $1}')
		if [ "$count" -gt "$min_logins" ]; then
			echo "User: '$user' Logins: $count"
		fi
	done <<< "$login_info"
}

handle_args "$@"
validate_inputs
process_logins

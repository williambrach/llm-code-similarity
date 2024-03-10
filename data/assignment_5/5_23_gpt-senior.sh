
show_help() {
	echo
	echo "Script Version 2.0"
	echo
	echo "How to use: $0 options"
	echo
	echo "Options:"
	echo " -h: Show this help message and exit"
	echo
	echo " -m: Display users with machine count exceeding 10 by default"
	echo
	echo " -m <number>: Display users with machine count exceeding <number>"
	echo
	echo " -g <log_file>: Specify a log file for user login data. Defaults to 'login.2021'"
	echo
	echo "Example:"
	echo " $0 -g access.log -m 5"
	echo
}

process_args() {
	while [ $# -gt 0 ]; do
		case $1 in
			-h)
				show_help
				exit 0
				;;
			-m)
				shift
				machine_threshold="$1"
				;;
			-g)
				shift
				login_data_file="$1"
				;;
			*)
				echo "Error: Unrecognized option '$1'" >&2
				exit 1
				;;
		esac
		shift
	done
}

validate_input() {
	if [ -z "$machine_threshold" ]; then
		machine_threshold=10
	fi
	if ! [[ "$machine_threshold" =~ ^[0-9]+$ ]]; then
		echo "Error: '$machine_threshold' is not a valid number for -m option" >&2
		exit 1
	fi
	if [ -z "$login_data_file" ]; then
		login_data_file="login.2021"
	fi
	if [ ! -f "$login_data_file" ]; then
		echo "Error: File '$login_data_file' does not exist" >&2
		exit 1
	fi
}

analyze_logins() {
	login_records=$(last -f "$login_data_file" | awk '$3 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { print $1, $3 }' | sort | uniq -c | sort -nr)
	while read -r record; do
		user=$(echo "$record" | awk '{print $2}')
		count=$(echo "$record" | awk '{print $1}')
		if [ "$count" -gt "$machine_threshold" ]; then
			echo "User: '$user' Count: $count"
		fi
	done <<< "$login_records"
}

process_args "$@"
validate_input
analyze_logins

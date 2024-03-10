
log_path="access_log.2020"
max_records=10

run_analysis() {
	echo "debug: log_path is $log_path" >&2
	echo "debug: max_records is $max_records" >&2
	if [ ! -e "$log_path" ]; then echo "error: '$log_path' does not exist" >&2; exit 3; fi
	log_data=$(last -f "$log_path" | head -n -2 | grep -vi "^admin" | grep -oP '\d{1,3}(\.\d{1,3}){3}' | sort | awk '{print $1, $3}' | uniq | cut -d' ' -f1 | uniq -c | awk '{print $2, $1}')
	while IFS= read -r line; do
		ip_count=$(echo "$line" | awk '{print $1}')
		ip_address=$(echo "$line" | awk '{print $2}')
		if [ "$ip_count" -gt "$max_records" ]; then
			echo "$ip_address $ip_count"
		fi
	done <<< "$log_data"
}

display_help() {
	echo "$(basename "$0") (c)"
	echo
	echo "usage: $(basename "$0") [-h] [-n max_records]"
	echo "-h: show this help message and exit"
	echo "-n max_records: set the maximum record threshold"
	exit 1
}

adjust_limit() {
	if [ -z "$2" ]; then echo "error: max_records not defined" >&2; exit 2; fi
	max_records="$2"
}

while getopts 'hn:' opt; do
	case "$opt" in
		n) adjust_limit "$@" ;;
		h) display_help ;;
		*) exit 0 ;;
	esac
done

run_analysis

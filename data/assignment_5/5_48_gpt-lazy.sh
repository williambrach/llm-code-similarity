log_file="access_log.2020"
record_limit=10
execute_script() {
	printf 'debug: log_file is %s\n' "$log_file" 1>&2
	printf 'debug: record_limit is %s\n' "$record_limit" 1>&2
	[[ ! -f ${log_file} ]] && printf "error: '%s': file does not exist\n" "$log_file" 1>&2 && exit 3
	log_contents=$(last -f "$log_file" | head -n -2 | grep -vi "^admin" | grep -Eo '[0-9]{1,3}(\.[0-9]{1,3}){3}' | sort | awk '{print $1, $3}' | uniq | cut -d ' ' -f 1 | uniq -c | awk '{print $2, $1}')
	while IFS= read -r entry; do
		connection_count=$(cut -d ' ' -f 1 <<<"$entry")
		user=$(cut -d ' ' -f 2 <<<"$entry")
		if [[ "$connection_count" -gt "$record_limit" ]]; then
			printf '%s %s\n' "$user" "$connection_count"
		fi
	done <<<"$log_contents"
}
show_help() {
	printf '%s (c)' "$(basename "$0")"
	printf '\n\n'
	printf 'usage: %s [-h] [-n record_limit]\n' "$(basename "$0")"
	echo '-h: display this help and exit'
	echo '-n record_limit: specify the record limit'
	exit 1
}
set_limit() {
	[[ -z ${2} ]] && printf 'error: record limit not specified\n' 1>&2 && exit 2
	record_limit="$2"
}
while getopts 'hn:' option; do
	case "$option" in
	n) set_limit "$@" ;;
	h) show_help exit 1 ;;
	*) exit 0 ;;
	esac
done
execute_script "$0"

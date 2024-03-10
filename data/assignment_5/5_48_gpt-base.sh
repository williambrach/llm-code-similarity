
logFileName="access_log.2020"
maxRecords=10

processLog() {
	echo "debug: logFileName is $logFileName" >&2
	echo "debug: maxRecords is $maxRecords" >&2
	if [ ! -f "$logFileName" ]; then echo "error: '$logFileName' not found" >&2; exit 3; fi
	logData=$(last -f "$logFileName" | head -n -2 | grep -vi "^admin" | grep -oP '\d{1,3}(\.\d{1,3}){3}' | sort | uniq | cut -d' ' -f1 | uniq -c | awk '{print $2, $1}')
	while IFS= read -r line; do
		visits=$(echo "$line" | awk '{print $1}')
		address=$(echo "$line" | awk '{print $2}')
		if [ "$visits" -gt "$maxRecords" ]; then
			echo "$address $visits"
		fi
	done <<< "$logData"
}

displayHelp() {
	echo "$(basename "$0") (c)"
	echo
	echo "usage: $(basename "$0") [-h] [-n maxRecords]"
	echo "-h: display this help message and exit"
	echo "-n maxRecords: define the maximum number of records"
	exit 1
}

updateThreshold() {
	if [ -z "$2" ]; then echo "error: maxRecords not specified" >&2; exit 2; fi
	maxRecords="$2"
}

while getopts 'hn:' opt; do
	case "$opt" in
		n) updateThreshold "$@" ;;
		h) displayHelp ;;
		*) exit 0 ;;
	esac
done

processLog

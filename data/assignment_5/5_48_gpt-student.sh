
logFile="access_log.2020"
recordThreshold=10

analyzeLog() {
	echo "debug: logFile is $logFile" >&2
	echo "debug: recordThreshold is $recordThreshold" >&2
	if [ ! -e "$logFile" ]; then echo "error: '$logFile' does not exist" >&2; exit 3; fi
	logContent=$(last -f "$logFile" | head -n -2 | grep -vi "^admin" | grep -oP '\d{1,3}(\.\d{1,3}){3}' | sort | awk '{print $1, $3}' | uniq | cut -d' ' -f1 | uniq -c | awk '{print $2, $1}')
	while IFS= read -r record; do
		count=$(echo "$record" | awk '{print $1}')
		ip=$(echo "$record" | awk '{print $2}')
		if [ "$count" -gt "$recordThreshold" ]; then
			echo "$ip $count"
		fi
	done <<< "$logContent"
}

showHelp() {
	echo "$(basename "$0") (c)"
	echo
	echo "usage: $(basename "$0") [-h] [-n recordThreshold]"
	echo "-h: show this help message and exit"
	echo "-n recordThreshold: set the maximum record threshold"
	exit 1
}

setThreshold() {
	if [ -z "$2" ]; then echo "error: recordThreshold not defined" >&2; exit 2; fi
	recordThreshold="$2"
}

while getopts 'hn:' option; do
	case "$option" in
		n) setThreshold "$@" ;;
		h) showHelp ;;
		*) exit 0 ;;
	esac
done

analyzeLog

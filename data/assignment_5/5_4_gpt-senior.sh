
min_count=10
show_usage() {
	echo "Usage Instructions"
	echo "Command: [-h] [-t] <value> " >&1
	echo "-t <value>	Specify minimum count of IP connections per user to display" >&1
	echo "-t		Displays users with at least 10 IP connections" >&1
	echo "-h		Displays help information." >&1
}
aggregate_data() {
	sorted_data=$(last | awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{print $1, $3}' | sort | uniq -c | sort -nr)
	local limit=$1
	echo "$sorted_data" | while read num login; do
		if [ "$num" -gt "$limit" ]; then
			echo "User: '$login' - Connections: '$num'" >&1
		fi
	done
}
while getopts ":ht:" opt; do
	case $opt in
	h)
		show_usage
		exit 0
		;;
	t)
		if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
			echo "Error: -t option requires a numeric value" >&2
			exit 1
		fi
		min_count=$OPTARG
		;;
	?)
		echo "Error: Unknown option: -$OPTARG." >&2
		exit 1
		;;
	:)
		echo "Error: Option -$OPTARG needs a value." >&2
		exit 1
		;;
	esac
done
if [ -z "$min_count" ]; then
	echo "Error: Missing required argument." >&2
	show_usage
	exit 1
fi
aggregate_data "$min_count"

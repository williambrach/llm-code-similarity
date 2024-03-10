threshold=10
display_help() {
	echo "Task 5"
	echo "Usage: [-h] [-m] <number> " >&1
	echo "-m <number>	Set the threshold for displaying usernames with their number of IP addresses connected" >&1
	echo "-m		This will show the usernames with a minimum number of IPs as 10" >&1
	echo "-h		Shows this help message." >&1
}
process_data() {
	organized_data=$(last | awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{print $1, $3}' | sort | uniq)
	result_data=$(echo "$organized_data" | awk '{print $1}' | sort | uniq -c | sort -nr)
	local threshold=$1
	echo "$result_data" | while read count user; do
		if [ "$count" -gt "$threshold" ]; then
			echo "Result: '$user $count'" >&1
		fi
	done
}
while getopts ":hm:" option; do
	case $option in
	h)
		display_help
		exit 0
		;;
	m)
		if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
			echo "Error: -m argument must be a number" >&2
			exit 1
		fi
		threshold=$OPTARG
		;;
	\?)
		echo "Error: Invalid option: -$OPTARG." >&2
		exit 1
		;;
	:)
		echo "Error: Option -$OPTARG requires an argument." >&2
		exit 1
		;;
	esac
done
if [ -z "$threshold" ]; then
	echo "Error: A parameter is required." >&2
	display_help
	exit 1
fi
process_data "$threshold"


threshold=10
display_help() {
	echo "Usage Instructions"
	echo "Command: [-h] [-t] <value> " >&1
	echo "-t <value>	Specify minimum count of IP connections per user to display" >&1
	echo "-t		Displays users with at least 10 IP connections" >&1
	echo "-h		Displays help information." >&1
}
compile_and_show() {
	compiled_info=$(last | awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{print $1, $3}' | sort | uniq -c | sort -nr)
	local min_connections=$1
	echo "$compiled_info" | while read count user; do
		if [ "$count" -gt "$min_connections" ]; then
			echo "User: '$user' - Connections: '$count'" >&1
		fi
	done
}
while getopts ":ht:" option; do
	case $option in
	h)
		display_help
		exit 0
		;;
	t)
		if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
			echo "Error: -t option requires a numeric value" >&2
			exit 1
		fi
		threshold=$OPTARG
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
if [ -z "$threshold" ]; then
	echo "Error: Missing required argument." >&2
	display_help
	exit 1
fi
compile_and_show "$threshold"

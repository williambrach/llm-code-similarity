show_help() {
	echo "Usage: $0 [-h] [-c <count>]"
	echo "Parameters:"
	echo " -h		Displays this help message"
	echo " -c <count>	Identifies users logging in from more than n machines"
}
LIMIT=10
LOG_FILE="/public/samples/login_data.2020"
if [ ! -f "$LOG_FILE" ]; then
	echo "Error: 'login_data.2020 file not found.'"
	exit 1
fi
while (("$#")); do
	case "$1" in
	-c)
		if [[ "$2" =~ ^[0-9]+$ ]]; then
			LIMIT=$2
		else
			echo "Error: 'Invalid count format for -c option.'" >&2
			exit 1
		fi
		shift
		;;
	-h)
		show_help
		exit 0
		;;
	*)
		echo "Error: 'Unrecognized option.'" >&2
		exit 1
		;;
	esac
	shift
done
last -f "$LOG_FILE" -w -i | awk '{print $1, $3}' | head -n -2 | grep -v "0.0.0.0" | sort | uniq | cut -d' ' -f1 | uniq -c | sort -rn | awk -v limit=$LIMIT '{if ($1 > limit) print "Result: \047" $2, $1 "\047"}'
exit 0

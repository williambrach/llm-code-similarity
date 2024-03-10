assist() {
	echo
	echo "$0 version 2.0 (C)"
	echo
	echo "Usage: $0 [-h][-m <count>][-g <logfile>]"
	echo
	echo "Options:"
	echo "	-h: Display help and exit with 0"
	echo
	echo "	-m: Show users and number of machines, if machines are more than 10"
	echo
	echo "	-m <count>: Show users and number of machines, if machines are more than 'count'"
	echo
	echo "	-g <logfile>: Log file with login records, if -g is not used, 'login.2021' is the default"
	echo
	echo "Example usage:"
	echo " $0 -g logfile -m 5"
	echo
}
while (("$#")); do
	case "$1" in
	-h)
		assist
		exit 0
		;;
	-m)
		shift
		count="$1"
		;;
	-g)
		shift
		logfile="$1"
		;;
	-*)
		echo "'Error: \"$1\"': Invalid option" >&2
		exit 1
		;;
	*)
		echo "'Error: \"$1\"': Invalid argument" >&2
		exit 1
		;;
	esac
	shift
done
if [ -z "$count" ]; then
	count=10
fi
if ! [[ "$count" =~ ^[0-9]+$ ]]; then
	echo "'Error: $count': invalid number for -m" >&2
	exit 1
fi
if [ -z "$logfile" ]; then
	logfile="login.2021"
fi
if [ -e "$logfile" ]; then
	:
else
	echo "'Error: $logfile': file not found" >&2
	exit 1
fi
user_logins=$(last -f "$logfile" | awk '$3 ~/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { print $1, $3}' | sort | uniq)
for user_login in "${user_logins[@]}"; do
	result=$(echo "$user_login" | cut -d' ' -f1 | uniq -c | sort -r | awk -v count="$count" '$1 > count' | tr -s ' ' | cut -d " " -f2,3 | awk '{ printf "Result:'\''%-8s %4s'\''\n", $2, $1 }')
	echo "$result"
done

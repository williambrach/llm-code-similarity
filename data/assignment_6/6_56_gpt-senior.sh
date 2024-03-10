
#!/bin/bash

displayUsage() {
	echo "Usage of script.sh"
	echo -e "\nUsage: script.sh [-h] [-m <number>]\n"
	echo "Options:"
	echo "  -h  Show this help message"
	echo "  -m  Set a minimum threshold for evening logins (numeric value required)"
}

minimumLoginCount=-1

while getopts ":hm:" opt; do
	case ${opt} in
		h)
			displayUsage
			exit 0
			;;
		m)
			minimumLoginCount=${OPTARG}
			if ! [[ ${minimumLoginCount} =~ ^[0-9]+$ ]]; then
				echo "Error: Minimum login count must be a positive integer." >&2
				exit 1
			fi
			;;
		\?)
			echo "Invalid option: $OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

LOG_PATH="/public/samples/wtmp.2020"

if [ ! -e "${LOG_PATH}" ]; then
	echo "Error: Log file does not exist." >&2
	exit 1
fi

last -Rf "${LOG_PATH}" --time-format=full |
	tail -n +3 |
	cut -d' ' -f1,4-7 |
	sort -k1,1 -k2M -k3n -k4 |
	awk -v min="${minimumLoginCount}" '
BEGIN {
	month["Jan"] = 1; month["Feb"] = 2; month["Mar"] = 3;
	month["Apr"] = 4; month["May"] = 5; month["Jun"] = 6;
	month["Jul"] = 7; month["Aug"] = 8; month["Sep"] = 9;
	month["Oct"] = 10; month["Nov"] = 11; month["Dec"] = 12;
}
{
	split($4, time, ":");
	hour = time[1] time[2] time[3];
	if (!(hour > "050000" && hour < "220000")) {
		date = sprintf("%02d-%02d %s:%s", month[$2], $3, time[1], time[2]);
		loginCount[$1]++;
		lastLogin[$1] = date;
	}
}
END {
	for (user in loginCount) {
		if (loginCount[user] >= min) {
			printf "User: %s, Logins: %d, Last: %s\n", user, loginCount[user], lastLogin[user];
		}
	}
}'

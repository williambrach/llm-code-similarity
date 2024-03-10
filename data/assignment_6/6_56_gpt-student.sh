
#!/bin/bash

showHelp() {
	echo "Usage of login_monitor.sh"
	echo -e "\nUsage: login_monitor.sh [-h] [-t <threshold>]\n"
	echo "Options:"
	echo "  -h  Display this help message"
	echo "  -t  Specify a threshold for evening logins (must be a positive integer)"
}

threshold=-1

while getopts ":ht:" option; do
	case ${option} in
		h)
			showHelp
			exit 0
			;;
		t)
			threshold=${OPTARG}
			if ! [[ ${threshold} =~ ^[0-9]+$ ]]; then
				echo "Error: Threshold must be a positive integer." >&2
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

LOG_FILE="/public/samples/wtmp.2020"

if [ ! -f "${LOG_FILE}" ]; then
	echo "Error: Log file does not exist." >&2
	exit 1
fi

last -Rf "${LOG_FILE}" --time-format=full |
	tail -n +3 |
	cut -d' ' -f1,4-7 |
	sort -k1,1 -k2M -k3n -k4 |
	awk -v threshold="${threshold}" '
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
		userLogins[$1]++;
		recentLogin[$1] = date;
	}
}
END {
	for (user in userLogins) {
		if (userLogins[user] >= threshold) {
			printf "User: %s, Logins: %d, Last: %s\n", user, userLogins[user], recentLogin[user];
		}
	}
}'

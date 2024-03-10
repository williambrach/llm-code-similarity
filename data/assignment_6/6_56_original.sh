
#!/bin/bash

displayUsage() {
	echo "How to use login_tracker.sh"
	echo -e "\nSyntax: login_tracker.sh [-h] [-t <limit>]\n"
	echo "Flags:"
	echo "  -h  Show help information"
	echo "  -t  Set a limit for nighttime login attempts (positive integer required)"
}

limit=-1

while getopts ":ht:" opt; do
	case ${opt} in
		h)
			displayUsage
			exit 0
			;;
		t)
			limit=${OPTARG}
			if ! [[ ${limit} =~ ^[0-9]+$ ]]; then
				echo "Error: Limit must be a positive number." >&2
				exit 1
			fi
			;;
		?)
			echo "Invalid flag: $OPTARG" >&2
			exit 1
			;;
		:)
			echo "Flag -$OPTARG needs a value." >&2
			exit 1
			;;
	esac
done

LOGIN_FILE="/public/samples/wtmp.2020"

if [ ! -e "${LOGIN_FILE}" ]; then
	echo "Error: Cannot find the log file." >&2
	exit 1
fi

last -Rf "${LOGIN_FILE}" --time-format=full |
	tail -n +3 |
	cut -d' ' -f1,4-7 |
	sort -k1,1 -k2M -k3n -k4 |
	awk -v limit="${limit}" '
BEGIN {
	mon["Jan"] = 1; mon["Feb"] = 2; mon["Mar"] = 3;
	mon["Apr"] = 4; mon["May"] = 5; mon["Jun"] = 6;
	mon["Jul"] = 7; mon["Aug"] = 8; mon["Sep"] = 9;
	mon["Oct"] = 10; mon["Nov"] = 11; mon["Dec"] = 12;
}
{
	split($4, timeParts, ":");
	hour = timeParts[1] timeParts[2] timeParts[3];
	if (!(hour > "050000" && hour < "220000")) {
		formattedDate = sprintf("%02d-%02d %s:%s", mon[$2], $3, timeParts[1], timeParts[2]);
		loginCounts[$1]++;
		lastLogin[$1] = formattedDate;
	}
}
END {
	for (user in loginCounts) {
		if (loginCounts[user] >= limit) {
			printf "User: %s, Attempts: %d, Recent: %s\n", user, loginCounts[user], lastLogin[user];
		}
	}
}'

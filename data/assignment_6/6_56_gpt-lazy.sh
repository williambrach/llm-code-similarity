function showHelp() {
	printf "task_script.sh (C)\n\n"
	printf "Usage: task_script.sh [-h] [-m <number>]\n"
	printf "   -h: displays help information\n"
	printf "   -m [number]: minimum number of evening logins per user\n"
}
minLogins=-1
while getopts "hm:" option 2>/dev/null; do
	case $option in
	m)
		minLogins="$OPTARG"
		if ! [ "$minLogins" -eq "$minLogins" ] 2>/dev/null; then
			echo "Error: 'Number of logins must be numeric.'" >&2
			exit 1
		fi
		if [ "$minLogins" -lt "0" ]; then
			echo "Error: 'Number of logins must be zero or more.'" >&2
			exit 1
		fi
		;;
	h)
		showHelp
		exit 0
		;;
	:)
		echo "Error: \"Option $OPTARG needs a value\"" >&2
		exit 1
		;;
	?)
		echo "Error: 'Invalid command option'" >&2
		exit 1
		;;
	esac
done
LOG_FILE="/public/samples/wtmp.2020"
if ! [ -f "$LOG_FILE" ]; then
	echo "Error: 'Log file is missing.'" >&2
	exit 1
fi
last -Rf "$LOG_FILE" --time-format=full |
	head -n-2 |
	tr -s ' ' |
	sort -t' ' -k1,1 -k7n -k4M -k5n -k6d |
	awk -v minLogins="$minLogins" '
BEGIN {
    monthToNum["Jan"] = "1"; monthToNum["Feb"] = "2"; monthToNum["Mar"] = "3";
    monthToNum["Apr"] = "4"; monthToNum["May"] = "5"; monthToNum["Jun"] = "6";
    monthToNum["Jul"] = "7"; monthToNum["Aug"] = "8"; monthToNum["Sep"] = "9";
    monthToNum["Oct"] = "10"; monthToNum["Nov"] = "11"; monthToNum["Dec"] = "12";
}
{
    split($6, timeParts, ":"); 
    loginHour = timeParts[1] timeParts[2] timeParts[3];
    if (!(loginHour > "050000" && loginHour < "220000")) { 
	formattedTime = sprintf("%02d-%02d %s:%s", 
	    monthToNum[$4], 
	    $5, 
	    timeParts[1], 
	    timeParts[2]);
	userCounts[$1]++; 
	lastTime[$1] = formattedTime
    } 
}
END { 
    for(user in userCounts) { 
	if(userCounts[user] > minLogins) {
	    print "Result: '\''"  user, userCounts[user] " " lastTime[user]"'\''"
	} 
    }
}'

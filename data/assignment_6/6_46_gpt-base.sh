
numericCheck='^[0-9]+$'
logFile="/public/logs/access.2020"
if [[ ! -f "$logFile" || ! -r "$logFile" ]]; then
	echo "Error: Unable to access '$logFile'. File is missing or permission denied" >&2
	exit 1
fi

showUsage() {
	echo "How to use: $0 [-h] [-c <number>]"
	echo "-h: Show help information"
	echo "-c <number>: Display users with login attempts exceeding <number> during the specified timeframe"
	exit 0
}

if [[ $1 == "-h" && $2 ]]; then
	showUsage
elif [[ $1 == "-c" && $2 =~ $numericCheck && $3 ]] || [[ $1 ]]; then
	last -f $logFile | sed '1,2d' | sed -E 's/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)/\1/g;s/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' | sort -k5M -k6 | awk -v limit="$2" '
	{
		offset = ($7 == "-" ? 0 : 1)
		dateFormatted = $(4+offset)"-"$(5+offset)" "$(6+offset)
	}
	$(6+offset) >= "22" || $(6+offset) < "05" {
		userEntries[$1] = dateFormatted
		timesLoggedIn[$1]++
	}
	END{
		for(user in userEntries)
			if(limit == "" || limit < timesLoggedIn[user])
				printf "Output: '%s %d %s'\n", user, timesLoggedIn[user], userEntries[user]
	}
	'
else
	echo "Error: Incorrect parameter" >&2
	exit 1
fi
exit 0


digitPattern='^[0-9]+$'
logFilePath="/public/logs/access.2020"
if [[ ! -e "$logFilePath" || ! -r "$logFilePath" ]]; then
	echo "Error: Cannot read '$logFilePath': File does not exist or lacks permissions" >&2
	exit 1
fi

displayHelp() {
	echo "Usage: $0 [-h] [-c <count>]"
	echo "-h: Display this help message"
	echo "-c <count>: Show users who logged in more than <count> times in the specified period"
	exit 0
}

if [[ $1 == "-h" && -n $2 ]]; then
	displayHelp
elif [[ ($1 == "-c" && $2 =~ $digitPattern && -n $3) || -n $1 ]]; then
	last -f $logFilePath | sed '1,2d' | sed -E 's/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)/\1/g;s/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' | sort -k5M -k6 | awk -v threshold="$2" '
	{
		timeOffset = ($7 == "-" ? 0 : 1)
		formattedDate = $(4+timeOffset)"-"$(5+timeOffset)" "$(6+timeOffset)
	}
	$(6+timeOffset) >= "22" || $(6+timeOffset) < "05" {
		userLogins[$1] = formattedDate
		loginCount[$1]++
	}
	END{
		for(user in userLogins)
			if(threshold == "" || threshold < loginCount[user])
				printf "Result: '%s %d %s'\n", user, loginCount[user], userLogins[user]
	}
	'
else
	echo "Error: Invalid argument" >&2
	exit 1
fi
exit 0

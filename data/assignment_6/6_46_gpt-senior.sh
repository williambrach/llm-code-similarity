
regex_digits='^\d+$'
ACCESS_LOG=/public/logs/access.2020
if [[ ! -e "$ACCESS_LOG" || ! -r "$ACCESS_LOG" ]]; then
	echo "Error: Cannot read '$ACCESS_LOG': File does not exist or lacks permissions" >&2
	exit 1
fi
if [[ $1 == "-h" && -n $2 ]]; then
	echo "Usage: $0 [-h] [-c <count>]"
	echo "-h: Display this help message"
	echo "-c <count>: Show users who logged in more than <count> times in the specified period"
	exit 0
elif [[ ($1 == "-c" && $2 =~ $regex_digits && -n $3) || -n $1 ]]; then
	last -f $ACCESS_LOG | sed '1,2d' | sed -E 's/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)/\1/g;s/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' | sort -k5M -k6 | awk -v count="$2" '
	{
		offset = ($7 == "-" ? 0 : 1)
		dateTime = $(4+offset)"-"$(5+offset)" "$(6+offset)
	}
	$(6+offset) >= "22" || $(6+offset) < "05" {
		records[$1] = dateTime
		tally[$1]++
	}
	END{
		for(user in records)
			if(count == "" || count < tally[user])
				printf "Result: '%s %d %s'\n", user, tally[user], records[user]
	}
	'
else
	echo "Error: Invalid argument" >&2
	exit 1
fi
exit 0

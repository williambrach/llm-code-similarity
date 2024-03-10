pattern='^[0-9]+$'
LOG_FILE=/public/logs/access.2020
if [[ ! -r "$LOG_FILE" ]]; then
	echo "Error: Cannot read '$LOG_FILE': File does not exist or lacks permissions" 1>&2
	exit 1
fi
if [[ $1 == "-h" && -z $2 ]]; then
	cat <<EOF
	$0 (C)
	Usage: $0 [-h] [-c <count>]
	-h: Displays this help menu
	-c <count>: Shows users who logged in more than <count> times in the specified interval
EOF
	exit 0
elif [[ ($1 == "-c" && $2 =~ $pattern && -z $3) || -z $1 ]]; then
	last -f $LOG_FILE | head -n -2 | sed 's/Jan/01/g;s/Feb/02/g;s/Mar/03/g;s/Apr/04/g;s/May/05/g;s/Jun/06/g;s/Jul/07/g;s/Aug/08/g;s/Sep/09/g;s/Oct/10/g;s/Nov/11/g;s/Dec/12/g' | sort -n -k5 -k6 | awk -v cnt="$2" '
	
		{
			offset = ($7 == "-" ? 0 : 1 )
		
			date = $(4+offset)"-"$(5+offset)
			time = $(6+offset)
		}
		time >= "22" || time < "05" {
			info[$1] = date" "time
			count[$1]++
		}
		END{
			for(user in info)
				if(cnt == "" || cnt < count[user])
					printf "Result: \047"user" "count[user]" "info[user]"\047\n"
		}		
	'
else
	echo "Error: Invalid argument" 1>&2
	exit 1
fi
exit 0

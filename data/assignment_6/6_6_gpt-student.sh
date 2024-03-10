
#!/bin/bash

number_regex='^[0-9]+$'
LOG_PATH=/public/logs/access.2020

if [[ ! -r "$LOG_PATH" ]]; then
	echo "Error: Cannot read '$LOG_PATH': File does not exist or lacks permissions" >&2
	exit 1
fi

display_usage() {
	cat <<-EOF
	Usage of $0:
	-h: Show help information
	-c <count>: Display users with login counts exceeding <count> within the specified period
EOF
}

if [[ $1 == "-h" && -z $2 ]]; then
	display_usage
	exit 0
elif [[ ($1 == "-c" && $2 =~ $number_regex && -z $3) || -z $1 ]]; then
	last -f $LOG_PATH | head -n -2 | sed 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' | sort -k5M -k6 | awk -v count="$2" '
	{
		offset = ($7 == "-" ? 0 : 1)
		date = $(4+offset)"-"$(5+offset)
		time = $(6+offset)
	}
	time >= "22" || time < "05" {
		user_last_login[$1] = date" "time
		user_count[$1]++
	}
	END{
		for(user in user_last_login)
			if(count == "" || count < user_count[user])
				printf "User: %s, Count: %d, Last Login: %s\n", user, user_count[user], user_last_login[user]
	}
	'
else
	echo "Error: Incorrect arguments provided" >&2
	exit 1
fi
exit 0

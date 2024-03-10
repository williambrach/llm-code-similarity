
#!/bin/bash

digit_pattern='^[0-9]+$'
ACCESS_LOG=/public/logs/access.2020

if [[ ! -r "$ACCESS_LOG" ]]; then
	echo "Error: Cannot read '$ACCESS_LOG': File does not exist or lacks permissions" >&2
	exit 1
fi

if [[ $1 == "-h" && -z $2 ]]; then
	cat <<-EOF
	Usage of $0:
	-h: Show help information
	-c <count>: Display users with login counts exceeding <count> within the specified period
EOF
	exit 0
elif [[ ($1 == "-c" && $2 =~ $digit_pattern && -z $3) || -z $1 ]]; then
	last -f $ACCESS_LOG | head -n -2 | sed 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' | sort -k5M -k6 | awk -v threshold="$2" '
	{
		shift = ($7 == "-" ? 0 : 1)
		login_date = $(4+shift)"-"$(5+shift)
		login_time = $(6+shift)
	}
	login_time >= "22" || login_time < "05" {
		user_info[$1] = login_date" "login_time
		login_count[$1]++
	}
	END{
		for(user in user_info)
			if(threshold == "" || threshold < login_count[user])
				printf "User: %s, Count: %d, Last Login: %s\n", user, login_count[user], user_info[user]
	}
	'
else
	echo "Error: Incorrect arguments provided" >&2
	exit 1
fi
exit 0


#!/bin/bash

digit_pattern='^[0-9]+$'
LOG_FILE_PATH="/public/logs/access.2020"

if [[ ! -r "$LOG_FILE_PATH" ]]; then
	echo "Error: Cannot read '$LOG_FILE_PATH'. File is missing or permission denied." >&2
	exit 1
fi

function show_help {
	cat <<-EOF
	How to use $0:
	-h: Displays this help message
	-c <number>: Shows users with login attempts more than <number> in the given timeframe
EOF
}

if [[ $1 == "-h" && -z $2 ]]; then
	show_help
	exit 0
elif [[ ($1 == "-c" && $2 =~ $digit_pattern && -z $3) || -z $1 ]]; then
	last -f $LOG_FILE_PATH | head -n -2 | sed 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' | sort -k5M -k6 | awk -v limit="$2" '
	{
		adjust = ($7 == "-" ? 0 : 1)
		login_date = $(4+adjust)"-"$(5+adjust)
		login_time = $(6+adjust)
	}
	login_time >= "22" || login_time < "05" {
		last_login[$1] = login_date" "login_time
		login_attempts[$1]++
	}
	END{
		for(account in last_login)
			if(limit == "" || limit < login_attempts[account])
				printf "User: %s, Attempts: %d, Last Access: %s\n", account, login_attempts[account], last_login[account]
	}
	'
else
	echo "Error: Invalid arguments" >&2
	exit 1
fi
exit 0

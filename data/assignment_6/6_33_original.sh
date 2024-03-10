
#!/bin/bash

# Help guide
if [ "$1" = "--help" ] && [ -z "$2" ]; then
  echo "Evening Login Report

How to use: ./evening_logins.sh [--default] [--help] [--limit <value>]
    --default: Display logins from 22:00 to 5:00 including login frequency and most recent login without any arguments.
    --help: Show this guide.
    --limit <value>: List users with logins in the specified time frame exceeding <value> times, including frequency and last login."
  exit 0
fi

# Argument validation
if [ "$#" -gt 2 ] || { [ "$1" = "--limit" ] && [ -z "$2" ]; } || { [ "$1" != "--limit" ] && [ -n "$1" ]; } || { [ "$1" = "--help" ] && [ -n "$2" ]; }; then
  echo "Error: Wrong argument usage" >&2
  exit 1
fi

# Log file location
LOG_FILE="/public/samples/wtmp.2020"

# Log analysis
awk -v limit="$2" '
BEGIN {
  FS = "[ :]+"
  split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", months, " ")
  for (i = 1; i <= 12; i++) month_index[months[i]] = i
}
{
  if ((NF == 13 && ($7 >= 22 || $7 < 5) && ($10 >= 22 || $10 < 5)) || (NF == 12 && ($6 >= 22 || $6 < 5) && ($9 >= 22 || $9 < 5))) {
    user_logins[$1]++
    month = (NF == 13) ? month_index[$5] : month_index[$4]
    split(recent_login[$1], last_login, "[- :]")
    if (recent_login[$1] == "" || 
        (month > last_login[1]) || 
        (month == last_login[1] && ((NF == 13 && $6 > last_login[2]) || (NF == 12 && $5 > last_login[2]))) || 
        (month == last_login[1] && ((NF == 13 && $6 == last_login[2] && $7 > last_login[3]) || (NF == 12 && $5 == last_login[2] && $6 > last_login[3]))) || 
        (month == last_login[1] && ((NF == 13 && $6 == last_login[2] && $7 == last_login[3] && $8 > last_login[4]) || (NF == 12 && $5 == last_login[2] && $6 == last_login[3] && $7 > last_login[4]))) ) {
      recent_login[$1] = month "-" ((NF == 13) ? $6 : $5) " " ((NF == 13) ? $7 : $6) ":" ((NF == 13) ? $8 : $7)
    }
  }
}
END {
  for (user in user_logins) {
    if (user_logins[user] > limit) {
      print "User: " user, "Login Count: " user_logins[user], "Most Recent: " recent_login[user]
    }
  }
}' $LOG_FILE

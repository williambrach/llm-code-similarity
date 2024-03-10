
#!/bin/bash

# Display help information
if [[ $1 == "--help" && -z $2 ]]; then
  cat << EOF
Task 6 

Usage: task6_smith.sh [--default] [--help] [--count <number>]
    --default without arguments: Shows users logged in from 22:00 to 5:00, their login count, and last login time.
    --help: Displays this help message.
    --count <number>: Shows users logged in from 22:00 to 5:00 more than <number> times, their login count, and last login time.
EOF
  exit 0
fi

# Validate input arguments
if [[ $# -gt 2 || $1 == "--count" && -z $2 || $1 != "--count" && -n $1 || $1 == "--help" && -n $2 ]]; then
  echo "Error: Incorrect usage of arguments" >&2
  exit 1
fi

# Define the log file path
LOG_FILE="/public/samples/wtmp.2020"

# Process the log file
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
    split(last_login[$1], last, "[- :]")
    if (last_login[$1] == "" || 
        (month > last[1]) || 
        (month == last[1] && ((NF == 13 && $6 > last[2]) || (NF == 12 && $5 > last[2]))) || 
        (month == last[1] && ((NF == 13 && $6 == last[2] && $7 > last[3]) || (NF == 12 && $5 == last[2] && $6 > last[3]))) || 
        (month == last[1] && ((NF == 13 && $6 == last[2] && $7 == last[3] && $8 > last[4]) || (NF == 12 && $5 == last[2] && $6 == last[3] && $7 > last[4]))) ) {
      last_login[$1] = month "-" ((NF == 13) ? $6 : $5) " " ((NF == 13) ? $7 : $6) ":" ((NF == 13) ? $8 : $7)
    }
  }
}
END {
  for (user in user_logins) {
    if (user_logins[user] > limit) {
      print "User: " user, "Logins: " user_logins[user], "Last: " last_login[user]
    }
  }
}' $LOG_FILE

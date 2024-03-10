
#!/bin/bash

# Display help information
if [[ $1 == "--help" && -z $2 ]]; then
  cat << EOF
Display Nightly Logins

Usage: nightly_logins.sh [--default] [--help] [--threshold <number>]
    --default without arguments: Shows users logged in between 22:00 to 5:00, their login count, and last login time.
    --help: Displays this help message.
    --threshold <number>: Shows users logged in between 22:00 to 5:00 more than <number> times, their login count, and last login time.
EOF
  exit 0
fi

# Validate input arguments
if [[ $# -gt 2 || $1 == "--threshold" && -z $2 || $1 != "--threshold" && -n $1 || $1 == "--help" && -n $2 ]]; then
  echo "Error: Incorrect usage of arguments" >&2
  exit 1
fi

# Define the log file path
LOG_FILE_PATH="/public/samples/wtmp.2020"

# Analyze the log file
awk -v threshold="$2" '
BEGIN {
  FS = "[ :]+"
  split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", month_names, " ")
  for (i = 1; i <= 12; i++) month_indices[month_names[i]] = i
}
{
  if ((NF == 13 && ($7 >= 22 || $7 < 5) && ($10 >= 22 || $10 < 5)) || (NF == 12 && ($6 >= 22 || $6 < 5) && ($9 >= 22 || $9 < 5))) {
    login_counts[$1]++
    month = (NF == 13) ? month_indices[$5] : month_indices[$4]
    split(last_login_time[$1], last, "[- :]")
    if (last_login_time[$1] == "" || 
        (month > last[1]) || 
        (month == last[1] && ((NF == 13 && $6 > last[2]) || (NF == 12 && $5 > last[2]))) || 
        (month == last[1] && ((NF == 13 && $6 == last[2] && $7 > last[3]) || (NF == 12 && $5 == last[2] && $6 > last[3]))) || 
        (month == last[1] && ((NF == 13 && $6 == last[2] && $7 == last[3] && $8 > last[4]) || (NF == 12 && $5 == last[2] && $6 == last[3] && $7 > last[4]))) ) {
      last_login_time[$1] = month "-" ((NF == 13) ? $6 : $5) " " ((NF == 13) ? $7 : $6) ":" ((NF == 13) ? $8 : $7)
    }
  }
}
END {
  for (user in login_counts) {
    if (login_counts[user] > threshold) {
      print "User: " user, "Logins: " login_counts[user], "Last: " last_login_time[user]
    }
  }
}' $LOG_FILE_PATH

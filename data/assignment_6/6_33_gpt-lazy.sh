if [[ $1 == "-help" && -z $2 ]]; then
  echo "Task 6 "
  echo ""
  echo "Usage: task6_smith.sh [default] [-help] [-count <number>]"
  echo "    -default without arguments: Displays users who logged in between 22:00 to 5:00. Also, the program will show the number of times they logged in during this time and their last night login."
  echo "    -help: Shows help"
  echo "    -count <number>: Displays users who logged in between 22:00 to 5:00 more than <number> times. Also, the program will show the number of times they logged in during this time and their last night login."
  exit 0
fi
if [[ $# -gt 2 || $1 == "-count" && -z $2 || $1 != "-count" && -n $1 || $1 == "-help" && -n $2 ]]; then
  echo "Error: 'arguments': Incorrect argument format" >&2
  exit 1
fi
LOG_PATH="/public/samples/wtmp.2020"
last -f $LOG_PATH | awk -v count="$2" '
BEGIN {
  FS = "[ :]+"
  split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", month_names, " ")
  for(i=1; i<=12; i++) month_nums[month_names[i]] = i
}
{
  if ((NF == 13 && ($7 >= 22 || $7 < 5) && ($10 >= 22 || $10 < 5)) || (NF == 12 && ($6 >= 22 || $6 < 5) && ($9 >= 22 || $9 < 5))) {
    night_users[$1]++
    month_num = (NF == 13) ? month_nums[$5] : month_nums[$4]
    split(last_entry[$1], last_entry_split, "[- :]")
    if (last_entry[$1] == "" || 
        (month_num > last_entry_split[1]) || 
        (month_num == last_entry_split[1] && ((NF == 13 && $6 > last_entry_split[2]) || (NF == 12 && $5 > last_entry_split[2]))) || 
        (month_num == last_entry_split[1] && ((NF == 13 && $6 == last_entry_split[2] && $7 > last_entry_split[3]) || (NF == 12 && $5 == last_entry_split[2] && $6 > last_entry_split[3]))) || 
        (month_num == last_entry_split[1] && ((NF == 13 && $6 == last_entry_split[2] && $7 == last_entry_split[3] && $8 > last_entry_split[4]) || (NF == 12 && $5 == last_entry_split[2] && $6 == last_entry_split[3] && $7 > last_entry_split[4]))) ) {
      last_entry[$1] = month_num "-" ((NF == 13) ? $6 : $5) " " ((NF == 13) ? $7 : $6) ":" ((NF == 13) ? $8 : $7)
    }
  }
}
END {
  for (user in night_users) {
    if (night_users[user] > count) {
      print "Result: \047" user, night_users[user], last_entry[user] "\047"
    }
  }
}'

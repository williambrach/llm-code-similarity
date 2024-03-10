log_file="/public/logs/login_data.2020"
min_login_count=0
show_help() {
   echo "Enhanced ScriptOS (C)"
   echo ""
   echo "Usage: enhancedScriptOS.sh [-h] [-m <MIN>]"
   echo "   -h: display this message (help)"
   echo "   -m <MIN>: show users with more than <MIN> nighttime logins"
   exit 0
}
error_message() {
   echo "Error: '$(readlink -f "$0")': $1" >&2
   exit 1
}
verify_log_file() {
   if [ ! -f "$1" ]; then
      error_message "File '$1' not found."
   elif [ ! -r "$1" ]; then
      error_message "No read permissions for file '$1'"
   fi
}
while (("$#")); do
   case "$1" in
   -m)
      if [ -n "$2" ] && [ "$2" -eq "$2" ] 2>/dev/null && [ "$2" -ge "0" ] 2>/dev/null; then
         min_login_count="$2"
         shift 2
      else
         error_message "Option [-m <MIN>] requires a positive numeric value."
      fi
      ;;
   -h)
      show_help
      ;;
   -*)
      error_message "Unknown option '$1'"
      ;;
   *)
      break
      ;;
   esac
   shift
done
verify_log_file "$log_file"
processed_output=$(last -f "$log_file" -R --time-format=full | head -n -2 | sort -k 4M,5 -k 5,6 -k 7,7 | tr -s ' ' |
   awk '$6 >= "22:00:00" || $6 <= "05:00:00"')
echo "$processed_output" | awk -v min_count="$min_login_count" '{
  user_count[$1]++;
  split($6, time_parts, ":")
   
  month_names = "JanFebMarAprMayJunJulAugSepOctNovDec"
  month_index = sprintf("%02d", (index(month_names, $4) + 2) / 3)
 
  timestamp=mktime($7" "month_index" "$5" "time_parts[1]" "time_parts[2]" "time_parts[3])
  formatted_date = strftime("%m-%d", timestamp);
  recent_login[$1]=formatted_date" "time_parts[1]":"time_parts[2]
  
} 
END {
  for (user in user_count) 
    if (user_count[user] > min_count) 
    print "Result: '\''"user, user_count[user], recent_login[user]"'\''"
}'

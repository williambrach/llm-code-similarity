
log_path="/public/logs/login_data.2020"
minimum_logins=0

display_help() {
   echo "Advanced ScriptOS Interface"
   echo ""
   echo "Syntax: advancedScriptOS.sh [-h] [-m <MINIMUM>]"
   echo "   -h: show this help information"
   echo "   -m <MINIMUM>: display users with over <MINIMUM> late-night logins"
   exit 0
}

show_error() {
   echo "Error: '$(readlink -f "$0")': $1" >&2
   exit 1
}

check_log_file() {
   if [ ! -e "$1" ]; then
      show_error "Log file '$1' is missing."
   elif [ ! -r "$1" ]; then
      show_error "Cannot read log file '$1'."
   fi
}

while [ "$#" -gt 0 ]; do
   case "$1" in
   -m)
      if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 0 ]; then
         minimum_logins="$2"
         shift
      else
         show_error "The -m option requires a non-negative integer."
      fi
      shift
      ;;
   -h)
      display_help
      ;;
   -*)
      show_error "Unrecognized option: $1"
      ;;
   *)
      break
      ;;
   esac
done

check_log_file "$log_path"
processed_logs=$(last -f "$log_path" -R --time-format=iso | head -n -2 | sort -k 4M,5 -k 5,6 -k 7,7 | tr -s ' ' |
   awk '$6 >= "22:00:00" || $6 <= "05:00:00"')

echo "$processed_logs" | awk -v min="$minimum_logins" '{
  counts[$1]++;
  split($6, parts, ":")
   
  months = "JanFebMarAprMayJunJulAugSepOctNovDec"
  idx = sprintf("%02d", (index(months, $4) + 2) / 3)
 
  ts=mktime($7" "idx" "$5" "parts[1]" "parts[2]" "parts[3])
  date_format = strftime("%m-%d", ts);
  last_login[$1]=date_format" "parts[1]":"parts[2]
  
} 
END {
  for (u in counts) 
    if (counts[u] > min) 
    print "User: '\''"u, counts[u], last_login[u]"'\''"
}'

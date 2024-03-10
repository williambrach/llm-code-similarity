
logPath="/public/logs/login_data.2020"
minimumLogins=0

usageGuide() {
   echo "Enhanced ScriptOS Utility"
   echo ""
   echo "Usage: scriptOS.sh [-h] [-m <MIN>]"
   echo "   -h: display help text"
   echo "   -m <MIN>: show users with over <MIN> late-night logins"
   exit 0
}

errorHandler() {
   echo "Error: '$(readlink -f "$0")': $1" >&2
   exit 1
}

checkLog() {
   if [ ! -f "$1" ]; then
      errorHandler "Missing log file '$1'."
   elif [ ! -r "$1" ]; then
      errorHandler "Log file '$1' is unreadable."
   fi
}

while [ "$#" -gt 0 ]; do
   case "$1" in
   -m)
      if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 0 ]; then
         minimumLogins="$2"
         shift
      else
         errorHandler "Option -m needs a non-negative integer."
      fi
      shift
      ;;
   -h)
      usageGuide
      ;;
   -*)
      errorHandler "Option $1 is not supported."
      ;;
   *)
      break
      ;;
   esac
done

checkLog "$logPath"
nightlyLogins=$(last -f "$logPath" -R --time-format=iso | head -n -2 | sort -k 4M,5 -k 5,6 -k 7,7 | tr -s ' ' |
   awk '$6 >= "22:00:00" || $6 <= "05:00:00"')

echo "$nightlyLogins" | awk -v min="$minimumLogins" '{
  counts[$1]++;
  split($6, parts, ":")
   
  months = "JanFebMarAprMayJunJulAugSepOctNovDec"
  index = sprintf("%02d", (index(months, $4) + 2) / 3)
 
  time=mktime($7" "index" "$5" "parts[1]" "parts[2]" "parts[3])
  dateFormatted = strftime("%m-%d", time);
  lastLogin[$1]=dateFormatted" "parts[1]":"parts[2]
  
} 
END {
  for (user in counts) 
    if (counts[user] > min) 
    print "User: '\''"user, counts[user], lastLogin[user]"'\''"
}'

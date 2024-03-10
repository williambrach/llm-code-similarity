
logDirectory="/public/logs/login_data.2020"
minLogins=0

showUsage() {
   echo "Advanced ScriptOS Interface"
   echo ""
   echo "Syntax: scriptOS.sh [-h] [-m <MINIMUM>]"
   echo "   -h: show this help information"
   echo "   -m <MINIMUM>: display users with more than <MINIMUM> late-night logins"
   exit 0
}

displayError() {
   echo "Error: '$(readlink -f "$0")': $1" >&2
   exit 1
}

validateLogFile() {
   if [ ! -e "$1" ]; then
      displayError "Log file '$1' is missing."
   elif [ ! -r "$1" ]; then
      displayError "Cannot read log file '$1'."
   fi
}

while [ "$#" -gt 0 ]; do
   case "$1" in
   -m)
      if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 0 ]; then
         minLogins="$2"
         shift
      else
         displayError "The -m option requires a non-negative integer."
      fi
      shift
      ;;
   -h)
      showUsage
      ;;
   -*)
      displayError "Unrecognized option: $1"
      ;;
   *)
      break
      ;;
   esac
done

validateLogFile "$logDirectory"
lateNightLogins=$(last -f "$logDirectory" -R --time-format=iso | head -n -2 | sort -k 4M,5 -k 5,6 -k 7,7 | tr -s ' ' |
   awk '$6 >= "22:00:00" || $6 <= "05:00:00"')

echo "$lateNightLogins" | awk -v min="$minLogins" '{
  userCounts[$1]++;
  split($6, timeParts, ":")
   
  monthAbbr = "JanFebMarAprMayJunJulAugSepOctNovDec"
  monthIndex = sprintf("%02d", (index(monthAbbr, $4) + 2) / 3)
 
  timestamp=mktime($7" "monthIndex" "$5" "timeParts[1]" "timeParts[2]" "timeParts[3])
  formattedDate = strftime("%m-%d", timestamp);
  recentLogin[$1]=formattedDate" "timeParts[1]":"timeParts[2]
  
} 
END {
  for (user in userCounts) 
    if (userCounts[user] > min) 
    print "User: '\''"user, userCounts[user], recentLogin[user]"'\''"
}'


#!/bin/bash

show_usage() {
  echo "Login Analysis Tool"
  echo
  echo "Usage: $0 [-h] [-c <count>] [-p <path_to_wtmp>]"
  echo "   -h                Show this help message"
  echo "   -c <count>        Number of logins to show (optional)"
  echo "   -p <path_to_wtmp> Path to 'last' command output file (optional)"
  exit 0
}

log_file="/var/log/wtmp"
while getopts ":hc:p:" option; do
  case $option in
    h)
      show_usage
      ;;
    c)
      login_count=$OPTARG
      if ! [[ $login_count =~ ^[0-9]+$ ]]; then
        echo "Error: '-c $login_count' is not a valid number." >&2
        exit 1
      fi
      ;;
    p)
      log_file=$OPTARG
      ;;
    \?)
      echo "Error: Unknown option '-$OPTARG'" >&2
      exit 1
      ;;
    :)
      echo "Error: Option '-$OPTARG' requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ ! -f "$log_file" ]; then
  echo "Error: The file '$log_file' does not exist." >&2
  exit 1
fi

night_start="22:00"
night_end="05:00"
login_data=$(last -f $log_file)
night_logins=$(echo "$login_data" | awk -v start="$night_start" -v end="$night_end" \
  'BEGIN{
         month["Jan"]="01";
         month["Feb"]="02";
         month["Mar"]="03";
         month["Apr"]="04";
         month["May"]="05";
         month["Jun"]="06";
         month["Jul"]="07";
         month["Aug"]="08";
         month["Sep"]="09";
         month["Oct"]="10";
         month["Nov"]="11";
         month["Dec"]="12";
       }
       ($7 >= start || $7 <= end) && NF > 9 && $8 != "still" {
         if (!recorded[$1]){
           recorded[$1]=month[$5] "-" $6 " " $7
         }
         print $1, recorded[$1]
       }' | sort | uniq -c | sort -nr)

if [ -n "$login_count" ]; then
  echo "$night_logins" | awk -v count="$login_count" '$1 > count' | awk '$2 != ""' |
    awk '{print $2 " " $1 " " $3 " " $4}'
else
  echo "$night_logins" | awk '$2 != ""' | awk '{print $2 " " $1 " " $3 " " $4}'
fi

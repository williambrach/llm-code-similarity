function show_instructions {
  echo "Homework 6 (C)"
  echo
  echo "How to use: $0 [-h] [-c <count>] [-p <path_to_file>]"
  echo "   -h          Show help information"
  echo "   -c <count>  Define the count of logins to show (optional)"
  echo "   -p <path_to_file> Set the path to the 'last' command output file (optional)"
  exit 0
}
login_file="/var/log/wtmp"
while getopts ":hc:p:" option; do
  case $option in
  h)
    show_instructions
    ;;
  c)
    login_count=$OPTARG
    if ! [[ $login_count =~ ^[0-9]+$ ]]; then
      echo "Error: '-c $login_count': Invalid count." >&2
      exit 1
    fi
    ;;
  p)
    login_file=$OPTARG
    ;;
  \?)
    echo "Error: Invalid option '-$OPTARG'" >&2
    exit 1
    ;;
  :)
    echo "Error: Option '-$OPTARG' needs a value." >&2
    exit 1
    ;;
  esac
done
if [ ! -f "$login_file" ]; then
  echo "Error: File '$login_file' not found" >&2
  exit 1
fi
begin_time="22:00"
finish_time="05:00"
last_output=$(last -f $login_file)
overnight_logins=$(echo "$last_output" | awk -v start="$begin_time" -v end="$finish_time" \
  'BEGIN{         # dictionary for output format mm-dd hh:mm 
         month_map["Jan"]="01";
         month_map["Feb"]="02";
         month_map["Mar"]="03";
         month_map["Apr"]="04";
         month_map["May"]="05";
         month_map["Jun"]="06";
         month_map["Jul"]="07";
         month_map["Aug"]="08";
         month_map["Sep"]="09";
         month_map["Oct"]="10";
         month_map["Nov"]="11";
        month_map["Dec"]="12";
        }
        ($7 >= start || $7 <= end) && NF > 9 && $8 != "still"	{ # check if time is within limits,
        if (!first_seen[$1]){
                first_seen[$1]=month_map[$5] "-" $6 " " $7 # Save the first seen time
        }
        print $1, first_seen[$1] 
     }' | sort | uniq -c | sort -nr) # count the overnight sessions per user
if [ -n "$login_count" ]; then                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                # display with limit
  echo "$overnight_logins" | awk -v limit="$login_count" '$1 > limit' | awk '$2 != ""' |
    awk '{print $2" " $1 " " $3 " " $4}'
else # display all
  echo "$overnight_logins" | awk '$2 != ""' | awk '{print $2 " " $1 " " $3 " " $4}'
fi

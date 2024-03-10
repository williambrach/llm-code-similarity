
#!/bin/bash

display_help() {
  echo "User Login Analysis Utility"
  echo
  echo "Syntax: $0 [-h] [-n <number>] [-f <wtmp_file_path>]"
  echo "   -h                Display help information"
  echo "   -n <number>       Specify the number of login records to display (optional)"
  echo "   -f <wtmp_file_path> Specify the file path for 'last' command output (optional)"
  exit 0
}

wtmp_path="/var/log/wtmp"
while getopts ":hn:f:" opt; do
  case $opt in
    h)
      display_help
      ;;
    n)
      record_count=$OPTARG
      if ! [[ $record_count =~ ^[0-9]+$ ]]; then
        echo "Error: '-n $record_count' is not a valid number." >&2
        exit 1
      fi
      ;;
    f)
      wtmp_path=$OPTARG
      ;;
    ?)
      echo "Error: Invalid option '-$OPTARG'" >&2
      exit 1
      ;;
    :)
      echo "Error: Missing argument for '-$OPTARG'." >&2
      exit 1
      ;;
  esac
done

if [ ! -f "$wtmp_path" ]; then
  echo "Error: File '$wtmp_path' not found." >&2
  exit 1
fi

evening_start="22:00"
morning_end="05:00"
login_info=$(last -f $wtmp_path)
evening_logins=$(echo "$login_info" | awk -v start="$evening_start" -v end="$morning_end" \
  'BEGIN{
         mth["Jan"]="01";
         mth["Feb"]="02";
         mth["Mar"]="03";
         mth["Apr"]="04";
         mth["May"]="05";
         mth["Jun"]="06";
         mth["Jul"]="07";
         mth["Aug"]="08";
         mth["Sep"]="09";
         mth["Oct"]="10";
         mth["Nov"]="11";
         mth["Dec"]="12";
       }
       ($7 >= start || $7 <= end) && NF > 9 && $8 != "still" {
         if (!seen[$1]){
           seen[$1]=mth[$5] "-" $6 " " $7
         }
         print $1, seen[$1]
       }' | sort | uniq -c | sort -nr)

if [ -n "$record_count" ]; then
  echo "$evening_logins" | awk -v num="$record_count" '$1 > num' | awk '$2 != ""' |
    awk '{print $2 " " $1 " " $3 " " $4}'
else
  echo "$evening_logins" | awk '$2 != ""' | awk '{print $2 " " $1 " " $3 " " $4}'
fi

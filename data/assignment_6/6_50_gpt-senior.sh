
#!/bin/bash

display_help() {
  echo "Assignment 6 (C)"
  echo
  echo "Usage: $0 [-h] [-n <number>] [-f <file_path>]"
  echo "   -h                Display this help message"
  echo "   -n <number>       Specify the number of logins to display (optional)"
  echo "   -f <file_path>    Specify the file path for 'last' command output (optional)"
  exit 0
}

wtmp_file="/var/log/wtmp"
while getopts ":hn:f:" opt; do
  case $opt in
    h)
      display_help
      ;;
    n)
      num_logins=$OPTARG
      if ! [[ $num_logins =~ ^[0-9]+$ ]]; then
        echo "Error: '-n $num_logins' is not a valid number." >&2
        exit 1
      fi
      ;;
    f)
      wtmp_file=$OPTARG
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

if [ ! -f "$wtmp_file" ]; then
  echo "Error: The file '$wtmp_file' does not exist." >&2
  exit 1
fi

start_time="22:00"
end_time="05:00"
last_data=$(last -f $wtmp_file)
nighttime_logins=$(echo "$last_data" | awk -v begin="$start_time" -v finish="$end_time" \
  'BEGIN{
         mon["Jan"]="01";
         mon["Feb"]="02";
         mon["Mar"]="03";
         mon["Apr"]="04";
         mon["May"]="05";
         mon["Jun"]="06";
         mon["Jul"]="07";
         mon["Aug"]="08";
         mon["Sep"]="09";
         mon["Oct"]="10";
         mon["Nov"]="11";
         mon["Dec"]="12";
       }
       ($7 >= begin || $7 <= finish) && NF > 9 && $8 != "still" {
         if (!seen[$1]){
           seen[$1]=mon[$5] "-" $6 " " $7
         }
         print $1, seen[$1]
       }' | sort | uniq -c | sort -nr)

if [ -n "$num_logins" ]; then
  echo "$nighttime_logins" | awk -v num="$num_logins" '$1 > num' | awk '$2 != ""' |
    awk '{print $2 " " $1 " " $3 " " $4}'
else
  echo "$nighttime_logins" | awk '$2 != ""' | awk '{print $2 " " $1 " " $3 " " $4}'
fi

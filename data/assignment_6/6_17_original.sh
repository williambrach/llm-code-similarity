
display_usage() {
  name_of_script=$(basename "$0")
  echo "How to use ${name_of_script}:"
  echo ""
  echo "Syntax: ${name_of_script} [-h] [-l <login_threshold>]"
  echo "  -l <login_threshold>: Set the minimum number of logins at night required for the report"
  echo "  -h: Show this help information"
  exit 0
}

login_threshold=0
while getopts ":hl:" opt; do
  case $opt in
    h)
      display_usage
      ;;
    l)
      login_threshold=$OPTARG
      if ! [[ "$login_threshold" =~ ^[0-9]+$ ]]; then
        echo "Error: <login_threshold> needs to be a non-negative integer" >&2
        exit 1
      fi
      ;;
    ?)
      echo "Error: Unrecognized option: -$OPTARG" >&2
      display_usage
      ;;
  esac
done

users_with_night_activity=$(last -f /public/samples/wtmp.2020 | awk '{time_of_login = (NF == 10) ? $7 : $6; split(time_of_login, time_parts, ":"); if (time_parts[1] >= 22 || time_parts[1] <= 4) print $1}' | sort -u)

while IFS= read -r username; do
  [[ -z "$username" ]] && continue
  count_of_night_logins=$(last -f /public/samples/wtmp.2020 | grep "$username" | awk '{time_of_login = (NF == 10) ? $7 : $6; split(time_of_login, time_parts, ":"); if (time_parts[1] >= 22 || time_parts[1] <= 4) print $1}' | wc -l)
  if [[ "$count_of_night_logins" -gt "$login_threshold" ]]; then
    last_night_login=$(last -f /public/samples/wtmp.2020 | grep "$username" | awk '{time_of_login = (NF == 10) ? $7 : $6; split(time_of_login, time_parts, ":"); if (time_parts[1] >= 22 || time_parts[1] <= 4) print sprintf("%02d", (index("JanFebMarAprMayJunJulAugSepOctNovDec", $5) + 2) / 3)"-"$6, $7}' | tail -1)
    echo "User: '${username} ${count_of_night_logins} ${last_night_login}'"
  fi
done <<< "$users_with_night_activity"

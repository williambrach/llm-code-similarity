show_help() {
  script_name=$(basename "$0")
  echo "$script_name (C)"
  echo ""
  echo "Usage: $script_name [-h] [-m <min_logins>]"
  echo "  -m <min_logins>: Set the minimum number of night logins required for report"
  echo "  -h: show this help information"
  exit 0
}
login_count_min=0
while getopts ":hm:" option; do
  case $option in
  h)
    show_help
    ;;
  m)
    login_count_min=$OPTARG
    if ! [[ "$login_count_min" =~ ^[0-9]+$ ]]; then
      echo "Error: <min_logins> must be a non-negative integer" >&2
      exit 1
    fi
    ;;
  ?)
    echo "Error: unrecognized option: -$OPTARG" >&2
    show_help
    ;;
  esac
done
night_logins=$(last -f /public/samples/wtmp.2020 | awk '{if (NF == 10) {login_time=$7} else {login_time=$6} split(login_time, time, ":"); if (time[1] >= 22 || time[1] <= 4) print $1}' | sort | uniq)
while read -r login_user; do
  if [ -z "$login_user" ]; then
    continue
  fi
  night_login_count=$(last -f /public/samples/wtmp.2020 | grep "$login_user" | awk '{if (NF == 10) {login_time=$7} else {login_time=$6} split(login_time, time, ":"); if (time[1] >= 22 || time[1] <= 4) print $1}' | wc -l)
  if [ "$night_login_count" -gt "$login_count_min" ]; then
    last_login_night=$(last -f /public/samples/wtmp.2020 | grep "$login_user" | awk '{if (NF == 10) {login_time=$7} else {login_time=$6} split(login_time, time, ":"); if (time[1] >= 22 || time[1] <= 4) print sprintf("%02d", (index("JanFebMarAprMayJunJulAugSepOctNovDec", $5) + 2) / 3)"-"$6, $7}' | tail -n 1)
    echo "Result: '$login_user $night_login_count $last_login_night'"
  fi
done <<<"$night_logins"

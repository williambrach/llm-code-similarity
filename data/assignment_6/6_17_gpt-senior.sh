
display_usage() {
  name_of_script=$(basename "${0}")
  echo "Usage of ${name_of_script}:"
  echo ""
  echo "Options: ${name_of_script} [-h] [-l <minimum_logins>]"
  echo "  -l <minimum_logins>: Specify the minimum number of logins at night to generate a report"
  echo "  -h: Display this help message"
  exit 0
}

min_login_threshold=0
while getopts ":hl:" opt; do
  case ${opt} in
    h)
      display_usage
      ;;
    l)
      min_login_threshold=${OPTARG}
      if ! [[ "${min_login_threshold}" =~ ^[0-9]+$ ]]; then
        echo "Error: <minimum_logins> should be a positive integer or zero" >&2
        exit 1
      fi
      ;;
    ?)
      echo "Error: Invalid option: -${OPTARG}" >&2
      display_usage
      ;;
  esac
done

night_login_users=$(last -f /public/samples/wtmp.2020 | awk '{login_hour = (NF == 10) ? $7 : $6; split(login_hour, hour, ":"); if (hour[1] >= 22 || hour[1] <= 4) print $1}' | sort -u)

while IFS= read -r user; do
  [[ -z "${user}" ]] && continue
  user_night_logins=$(last -f /public/samples/wtmp.2020 | grep "${user}" | awk '{login_hour = (NF == 10) ? $7 : $6; split(login_hour, hour, ":"); if (hour[1] >= 22 || hour[1] <= 4) print $1}' | wc -l)
  if [[ "${user_night_logins}" -gt "${min_login_threshold}" ]]; then
    last_night_login=$(last -f /public/samples/wtmp.2020 | grep "${user}" | awk '{login_hour = (NF == 10) ? $7 : $6; split(login_hour, hour, ":"); if (hour[1] >= 22 || hour[1] <= 4) print sprintf("%02d", (index("JanFebMarAprMayJunJulAugSepOctNovDec", $5) + 2) / 3)"-"$6, $7}' | tail -1)
    echo "User: '${user} ${user_night_logins} ${last_night_login}'"
  fi
done <<< "${night_login_users}"

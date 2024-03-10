
show_help() {
  script_name=$(basename "${0}")
  echo "Usage of ${script_name}:"
  echo ""
  echo "Options: ${script_name} [-h] [-m <min_logins>]"
  echo "  -m <min_logins>: Specify the minimum number of night logins for the report"
  echo "  -h: Display this help message"
  exit 0
}

min_logins_required=0
while getopts ":hm:" option; do
  case ${option} in
    h)
      show_help
      ;;
    m)
      min_logins_required=${OPTARG}
      if ! [[ "${min_logins_required}" =~ ^[0-9]+$ ]]; then
        echo "Error: <min_logins> must be a positive integer or zero" >&2
        exit 1
      fi
      ;;
    ?)
      echo "Error: Invalid option: -${OPTARG}" >&2
      show_help
      ;;
  esac
done

nightly_active_users=$(last -f /public/samples/wtmp.2020 | awk '{login_time = (NF == 10) ? $7 : $6; split(login_time, time, ":"); if (time[1] >= 22 || time[1] <= 4) print $1}' | sort -u)

while IFS= read -r user; do
  [[ -z "${user}" ]] && continue
  night_logins_count=$(last -f /public/samples/wtmp.2020 | grep "${user}" | awk '{login_time = (NF == 10) ? $7 : $6; split(login_time, time, ":"); if (time[1] >= 22 || time[1] <= 4) print $1}' | wc -l)
  if [[ "${night_logins_count}" -gt "${min_logins_required}" ]]; then
    recent_night_login=$(last -f /public/samples/wtmp.2020 | grep "${user}" | awk '{login_time = (NF == 10) ? $7 : $6; split(login_time, time, ":"); if (time[1] >= 22 || time[1] <= 4) print sprintf("%02d", (index("JanFebMarAprMayJunJulAugSepOctNovDec", $5) + 2) / 3)"-"$6, $7}' | tail -1)
    echo "User: '${user} ${night_logins_count} ${recent_night_login}'"
  fi
done <<< "${nightly_active_users}"

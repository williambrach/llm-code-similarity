
error_message() {
  echo >&2 "Error: '$1' - $2"
  exit 1
}

usage_guide() {
  echo "How to use: $0 [-h] [-c <count>]"
  echo "Arguments:"
  echo "  -h  Display this help message"
  echo "  -c  Display users with more than <count> logins"
  exit 0
}

enumerate_users() {
  login_data=$(last -w -i | awk '{print $1, $3}' | grep -v "0.0.0.0" | sort | uniq -c | sort -nr)
  echo "$login_data" | while IFS= read -r record; do
    count=$(echo "$record" | awk '{print $1}')
    username=$(echo "$record" | awk '{print $2}')
    if ((count > limit)); then
      echo "User: $username has logged in $count times"
    fi
  done
}

wtmp_file="/var/log/wtmp"
if [ ! -f "$wtmp_file" ]; then
  error_message "$wtmp_file" "Missing log file."
fi
if [ ! -r "$wtmp_file" ]; then
  error_message "$wtmp_file" "Log file not readable."
fi

limit=10
if [ "$#" -eq "0" ]; then
  enumerate_users
  exit 0
fi

while (( "$#" )); do
  case "$1" in
    -h)
      usage_guide
      ;;
    -c)
      shift
      if [[ $1 =~ ^[0-9]+$ ]]; then
        limit="$1"
        enumerate_users
      else
        echo >&2 "Error: '-c' option requires a numeric value."
        exit 1
      fi
      ;;
    *)
      echo >&2 "Error: Unrecognized option '$1'"
      exit 1
      ;;
  esac
  shift
done


error_message() {
  echo "Error: '$1' - $2" >&2
  exit 1
}

usage_guide() {
  echo "Usage: $0 [-h] [-n <count>]"
  echo "Options:"
  echo "  -h  Show help information"
  echo "  -n  Display users with login count exceeding <count>"
  exit 0
}

enumerate_users() {
  result=$(last -w -i | awk '{print $1, $3}' | grep -v "0.0.0.0" | sort | uniq -c | sort -nr)
  echo "$result" | while IFS= read -r entry; do
    count=$(echo "$entry" | awk '{print $1}')
    name=$(echo "$entry" | awk '{print $2}')
    if ((count > limit)); then
      echo "User: $name logged in $count times"
    fi
  done
}

log_path="/var/log/wtmp"
if [ ! -e "$log_path" ]; then
  error_message "$log_path" "Log file missing."
fi
if [ ! -r "$log_path" ]; then
  error_message "$log_path" "Cannot read log file."
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
    -n)
      shift
      if [[ $1 =~ ^[0-9]+$ ]]; then
        limit="$1"
        enumerate_users
      else
        echo "Error: '-n' requires a positive integer." >&2
        exit 1
      fi
      ;;
    *)
      echo "Error: Invalid option '$1'" >&2
      exit 1
      ;;
  esac
  shift
done

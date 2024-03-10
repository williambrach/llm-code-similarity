
display_error() {
  echo "Error: '$1' - $2" >&2
  exit 1
}

show_help() {
  echo "Usage: $0 [-h] [-c <count>]"
  echo "Options:"
  echo "  -h  Show help information"
  echo "  -c  Show users with login count above <count>"
  exit 0
}

list_active_users() {
  user_logins=$(last -w -i | awk '{print $1, $3}' | grep -v "0.0.0.0" | sort | uniq -c | sort -nr)
  echo "$user_logins" | while IFS= read -r line; do
    login_count=$(echo "$line" | awk '{print $1}')
    user_name=$(echo "$line" | awk '{print $2}')
    if ((login_count > threshold)); then
      echo "User: $user_name logged in $login_count times"
    fi
  done
}

log_file="/var/log/wtmp"
if [ ! -e "$log_file" ]; then
  display_error "$log_file" "Log file missing."
fi
if [ ! -r "$log_file" ]; then
  display_error "$log_file" "Cannot read log file."
fi

threshold=10
if [ "$#" -eq "0" ]; then
  list_active_users
  exit 0
fi

while (( "$#" )); do
  case "$1" in
    -h)
      show_help
      ;;
    -c)
      shift
      if [[ $1 =~ ^[0-9]+$ ]]; then
        threshold="$1"
        list_active_users
      else
        echo "Error: '-c' requires a positive integer." >&2
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

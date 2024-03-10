display_error() {
  echo "Error: '$1': $2" >&2
  exit 1
}
show_help() {
  echo "$0 (C)"
  echo ""
  echo "Usage: $0 [-h][-n <number>]"
  echo "-n: option to display users logged in from more than <number> machines"
  echo "-h: displays this help message"
  exit 0
}
list_users() {
  output=$(last -w -i | awk '{print $1, $3}' | grep -v "0.0.0.0" | sort -u | cut -d' ' -f1 | uniq -c | sort -r)
  echo "$output" | while read -r line; do
    user_count=$(echo "$line" | awk '{print $1}')
    user_name=$(echo "$line" | awk '{print $2}')
    if ((user_count > threshold)); then
      echo "User: $user_name $user_count"
    fi
  done
}
log_file="/var/log/wtmp"
if [ ! -f "$log_file" ]; then
  display_error "$log_file" "File does not exist."
fi
if [ ! -r "$log_file" ]; then
  display_error "$log_file" "Insufficient permissions to read the file."
fi
threshold=10
if [ "$#" == "0" ]; then
  list_users
  exit 0
fi
while [ "$#" -gt "0" ]; do
  case "$1" in
  -h)
    show_help
    ;;
  -n)
    shift
    if [[ $1 =~ ^[0-9]+$ ]]; then
      threshold="$1"
      list_users
    else
      echo "Error: A positive integer must follow -n." >&2
      exit 1
    fi
    ;;
  *)
    echo "Error: Unknown option \"$1\"" >&2
    exit 1
    ;;
  esac
  shift
done


show_usage() {
  echo "Guide for Task 3 (C)"
  echo
  echo "Usage: $0 [-h] [-g <group_id>]"
  echo "  -h       Display this help text."
  echo "  -g <group_id>  Show users belonging to a specific group ID."
  exit 0
}
group_id_filter=""
login_file_path="/public/samples/logins.2020"
user_file_path="/public/samples/users.2020"
for ((i = 1; i <= $#; i++)); do
  if ! [[ ${!i} =~ ^-h$|^-g$ ]]; then
    ((i--))
    if ! [[ $i -gt 0 && ${!i} == "-g" ]]; then
      ((i++))
      echo "Error: Invalid option: ${!i}" >&2
      exit 1
    else
      ((i++))
    fi
  fi
done
while getopts ":hg:" opt; do
  case $opt in
  h)
    show_usage
    ;;
  g)
    display_help_flag=0
    if [[ $# -gt 2 ]]; then
      for arg in "$@"; do
        if [[ "$arg" == "-h" ]]; then
          ((display_help_flag++))
        fi
      done
      if [[ $display_help_flag -eq 0 ]]; then
        echo "Error: Only one option is allowed" >&2
        exit 1
      fi
    fi
    group_id_filter="$OPTARG"
    if ! [[ "$group_id_filter" =~ ^[0-9]+$ ]]; then
      echo "Error: '-g' option requires a numeric group ID" >&2
      exit 1
    fi
    ;;
  :)
    echo "Error: Option '-$OPTARG' requires an argument" >&2
    exit 1
    ;;
  \?)
    echo "Error: Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done
recent_users=$(last -w -F -f "$login_file_path" | grep -v "still logged in" | awk '$1 != "" && $1 != "logins" && $1 != "logins.2020" && !seen[$1]++ { print $1 }')
for user in $recent_users; do
  user_group_id=$(grep "^$user:" "$user_file_path" | cut -d: -f4)
  if [[ -n $group_id_filter && $user_group_id == "$group_id_filter" ]]; then
    echo "Found: '$user $user_group_id'"
  elif [[ -z $group_id_filter ]]; then
    if [[ -n "$user_group_id" ]]; then
      echo "Found: '$user $user_group_id'"
    else
      echo "Found: '$user -no group'"
    fi
  fi
done


display_help() {
  echo "Guide for Task 3 (C)"
  echo
  echo "Usage: $0 [-h] [-g <group_id>]"
  echo "  -h       Display this help text."
  echo "  -g <group_id>  Show users belonging to a specific group ID."
  exit 0
}
group_filter=""
login_data="/public/samples/logins.2020"
user_data="/public/samples/users.2020"
for ((idx = 1; idx <= $#; idx++)); do
  if ! [[ ${!idx} =~ ^-h$|^-g$ ]]; then
    ((idx--))
    if ! [[ $idx -gt 0 && ${!idx} == "-g" ]]; then
      ((idx++))
      echo "Error: Invalid option: ${!idx}" >&2
      exit 1
    else
      ((idx++))
    fi
  fi
done
while getopts ":hg:" option; do
  case $option in
  h)
    display_help
    ;;
  g)
    help_flag=0
    if [[ $# -gt 2 ]]; then
      for arg in "$@"; do
        if [[ "$arg" == "-h" ]]; then
          ((help_flag++))
        fi
      done
      if [[ $help_flag -eq 0 ]]; then
        echo "Error: Only one option is allowed" >&2
        exit 1
      fi
    fi
    group_filter="$OPTARG"
    if ! [[ "$group_filter" =~ ^[0-9]+$ ]]; then
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
logged_users=$(last -w -F -f "$login_data" | grep -v "still logged in" | awk '$1 != "" && $1 != "logins" && $1 != "logins.2020" && !seen[$1]++ { print $1 }')
for user in $logged_users; do
  group_id=$(grep "^$user:" "$user_data" | cut -d: -f4)
  if [[ -n $group_filter && $group_id == "$group_filter" ]]; then
    echo "Found: '$user $group_id'"
  elif [[ -z $group_filter ]]; then
    if [[ -n "$group_id" ]]; then
      echo "Found: '$user $group_id'"
    else
      echo "Found: '$user -no group'"
    fi
  fi
done

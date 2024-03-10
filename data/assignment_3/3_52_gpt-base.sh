
display_help() {
  echo "Task 3 (C) Instructions"
  echo
  echo "Syntax: $0 [-h] [-g <group_id>]"
  echo "  -h       Show help information."
  echo "  -g <group_id>  List users in a specified group ID."
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
      echo "Error: Unrecognized option: ${!idx}" >&2
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
        echo "Error: Only a single option is permitted" >&2
        exit 1
      fi
    fi
    group_filter="$OPTARG"
    if ! [[ "$group_filter" =~ ^[0-9]+$ ]]; then
      echo "Error: '-g' requires a numeric group ID" >&2
      exit 1
    fi
    ;;
  :)
    echo "Error: Missing argument for option '-$OPTARG'" >&2
    exit 1
    ;;
  \?)
    echo "Error: Unrecognized option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done
logged_users=$(last -w -F -f "$login_data" | grep -v "still logged in" | awk '$1 != "" && $1 != "logins" && $1 != "logins.2020" && !seen[$1]++ { print $1 }')
for user in $logged_users; do
  gid=$(grep "^$user:" "$user_data" | cut -d: -f4)
  if [[ -n $group_filter && $gid == "$group_filter" ]]; then
    echo "User: '$user $gid'"
  elif [[ -z $group_filter ]]; then
    if [[ -n "$gid" ]]; then
      echo "User: '$user $gid'"
    else
      echo "User: '$user -no group'"
    fi
  fi
done

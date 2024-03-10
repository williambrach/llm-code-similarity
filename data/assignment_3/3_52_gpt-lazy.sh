show_instructions() {
  echo "Task 3 (C) Guide"
  echo
  echo "Syntax: $0 [-h] [-g <group_id>]"
  echo "  -h       Show this help message."
  echo "  -g <group_id>  List users from the given group ID."
  exit 0
}
group_criteria=""
logins_file="/public/samples/logins.2020"
users_file="/public/samples/users.2020"
for ((i = 1; i <= $#; i++)); do
  if ! [[ ${!i} == "-h" || ${!i} == "-g" ]]; then
    ((i--))
    if ! [[ ((i > 0)) && ${!i} == "-g" ]]; then
      ((i++))
      echo "Error: Unrecognized option: ${!i}" >&2
      exit 1
    else
      ((i++))
    fi
  fi
done
while getopts ":hg:" opt; do
  case $opt in
  h)
    show_instructions
    ;;
  g)
    has_help=0
    if [[ $# -gt 2 ]]; then
      for arg in "$@"; do
        if [[ "$arg" == "-h" ]]; then
          ((has_help++))
        fi
      done
      if [[ $has_help == 0 ]]; then
        echo "Error: Only a single option is permitted" >&2
        exit 1
      fi
    fi
    group_criteria="$OPTARG"
    if ! [[ "$group_criteria" =~ ^[0-9]+$ ]]; then
      echo "Error: Option '-g' requires a numeric group ID" >&2
      exit 1
    fi
    ;;
  :)
    echo "Error: Option '-$OPTARG' needs a valid argument" >&2
    exit 1
    ;;
  \?)
    echo "Error: Unrecognized option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done
recent_logins=$(last -w -F -f "$logins_file" | grep -v "still logged in" | awk '$1 != "" && $1 != "logins" && $1 != "logins.2020" && !seen[$1]++ { print $1 }')
for user in $recent_logins; do
  user_group=$(grep "^$user:" "$users_file" | awk -F: '{print $4}')
  if [[ -n $group_criteria && $user_group == "$group_criteria" ]]; then
    echo "Result: '$user $user_group'"
  elif [[ -z $group_criteria ]]; then
    if [[ -n "$user_group" ]]; then
      echo "Result: '$user $user_group'"
    else
      echo "Result: '$user -no group'"
    fi
  fi
done

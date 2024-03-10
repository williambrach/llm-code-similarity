threshold_limit=10
function display_help {
  echo "Task 5 (C)"
  echo -e "\nHow to use: $0 [-h][-n <number>]"
  echo "<number>: Minimum number of logins to display (default: $threshold_limit)"
  exit 0
}
while getopts ":hn:" option; do
  case $option in
  h)
    display_help
    ;;
  n)
    threshold_limit=$OPTARG
    ;;
  \?)
    echo "Error: 'Invalid option': -$OPTARG"
    exit 1
    ;;
  esac
done
logins=$(last -f /public/samples/wtmp.2020 | awk '!/wtmp/{print $1, $3}' | sort -u)
echo "$logins" | awk '{login_count[$1]++} END {for (login in login_count) {if (login_count[login] > '"$threshold_limit"') print "Result: '\''" login " " login_count[login] "'\''"}}'

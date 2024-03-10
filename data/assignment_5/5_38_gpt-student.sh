
threshold_logins=10
display_help() {
  echo "Usage Guide"
  echo -e "\nSyntax: $0 [-h] [-t <number>]"
  echo "<number>: Set the threshold for login count to report (default: $threshold_logins)"
  exit 0
}
while getopts ":ht:" option; do
  case $option in
    h)
      display_help
      ;;
    t)
      threshold_logins=$OPTARG
      ;;
    *)
      echo "Error: Unknown option: -$OPTARG"
      exit 1
      ;;
  esac
done
login_data=$(last -f /public/samples/wtmp.2020 | awk '!/wtmp/{print $1, $3}' | sort -k1,1 -u)
echo "$login_data" | awk -v min="$threshold_logins" '{login_count[$1]++} END {for (user in login_count) if (login_count[user] > min) print "User: '\''" user " " login_count[user] "'\''"}'

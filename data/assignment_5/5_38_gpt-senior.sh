
min_logins=10
help_message() {
  echo "Usage Guide"
  echo -e "\nSyntax: $0 [-h] [-n <value>]"
  echo "<value>: Set the minimum login count to report (default: $min_logins)"
  exit 0
}
while getopts ":hn:" opt; do
  case $opt in
    h)
      help_message
      ;;
    n)
      min_logins=$OPTARG
      ;;
    *)
      echo "Error: Unknown option: -$OPTARG"
      exit 1
      ;;
  esac
done
user_logins=$(last -f /public/samples/wtmp.2020 | awk '!/wtmp/{print $1, $3}' | sort -k1,1 -u)
echo "$user_logins" | awk -v limit="$min_logins" '{counts[$1]++} END {for (user in counts) if (counts[user] > limit) print "User: '\''" user " " counts[user] "'\''"}'

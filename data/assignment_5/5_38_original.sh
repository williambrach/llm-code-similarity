
login_threshold=10
help_message() {
  echo "How to Use"
  echo -e "\nCommand: $0 [-h] [-l <number>]"
  echo "<number>: Define login attempt limit for notification (default: $login_threshold)"
  exit 0
}
while getopts ":hl:" opt; do
  case $opt in
    h)
      help_message
      ;;
    l)
      login_threshold=$OPTARG
      ;;
    \?)
      echo "Error: Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done
user_logins=$(last -f /public/samples/wtmp.2020 | awk '!/wtmp/{print $1, $3}' | sort -k1,1 -u)
echo "$user_logins" | awk -v threshold="$login_threshold" '{counts[$1]++} END {for (user in counts) if (counts[user] > threshold) print "User: '\''" user " " counts[user] "'\''"}'

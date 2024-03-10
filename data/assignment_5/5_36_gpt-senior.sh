
HISTORY_PATH=/public/logs/login_data.2020
threshold=10
show_usage() {
    echo -e "UsageGuide.sh (C)"
    echo ""
    echo "Usage: UsageGuide.sh [-t <number>] [-help]"
    echo "[-t <number>]: show users with logins from more than 'threshold' devices"
    echo "[-help]: show this help information"
}
while [ "$#" -gt 0 ]; do
    case "$1" in
    -help)
            show_usage
            exit 0
            ;;
    -t)
            digit_regex='^[0-9]+$'
            shift
            if [[ "$1" =~ $digit_regex ]]; then
                    threshold=$1
            else
                    echo "Error: 'not a valid number'" >&2
                    exit 1
            fi
            ;;
    *)
            echo "Error: 'option not recognized'" >&2
            exit 1
            ;;
    esac
    shift
done
last -f $HISTORY_PATH -w -i | awk '{print $1,$3}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq | awk '{print $1}' | sort | uniq -c | awk -v count="$threshold" '$1>count' | sort -nr | awk '{print "Outcome: \047" $2,$1 "\047"}'

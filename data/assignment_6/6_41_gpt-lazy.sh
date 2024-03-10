show_help() {
    script_name=$(basename "$0")
    echo "$script_name (C)"
    echo ""
    echo "Usage: $script_name [-h] [-c <threshold>]"
    echo "  -h:  show this help message"
    echo "  -c:  display details for users with more than <threshold> entries during 22:00-5:00"
}
help_requested=0
while getopts ":hc:" option; do
    case ${option} in
    h)
        show_help
        help_requested=1
        ;;
    c)
        threshold=$OPTARG
        if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
            echo "Error: <threshold> must be a positive integer" >&2
            exit 1
        fi
        ;;
    \?)
        if [[ $OPTARG == "-"* ]]; then
            echo "Error: unrecognized option $OPTARG" >&2
            exit 1
        else
            echo "Error: Unrecognized option -$OPTARG" >&2
            exit 1
        fi
        ;;
    :)
        echo "Error: Option -$OPTARG needs a value." >&2
        exit 1
        ;;
    esac
done
analyze_logs() {
    last -f /public/samples/wtmp.2020 | awk -v threshold="${threshold:-0}" '
    BEGIN {
        start = "22:00"
        finish = "05:00"
        month_conversion["Jan"] = "01"
        month_conversion["Feb"] = "02"
        month_conversion["Mar"] = "03"
        month_conversion["Apr"] = "04"
        month_conversion["May"] = "05"
        month_conversion["Jun"] = "06"
        month_conversion["Jul"] = "07"
        month_conversion["Aug"] = "08"
        month_conversion["Sep"] = "09"
        month_conversion["Oct"] = "10"
        month_conversion["Nov"] = "11"
        month_conversion["Dec"] = "12"
    }
    {
        if ($7 ~ /:[0-9][0-9]/ && ($7 >= start || $7 <= finish)) {
            user_entries[$1]++
            month_digit = month_conversion[$5]
            day_digit = sprintf("%02d", $6)
            recent_log[$1] = month_digit "-" day_digit " " $7
        }
    }
    END {
        for (user in user_entries) {
            if (user_entries[user] > threshold) {
                print "Result: " "\047" user, user_entries[user], recent_log[user] "\047"
            }
        }
    }'
}
shift $((OPTIND - 1))
if [ "$#" -gt 0 ]; then
    echo "Error: Unrecognized argument(s): $*" >&2
    exit 1
elif [ $help_requested -eq 1 ]; then
    exit 0
fi
analyze_logs

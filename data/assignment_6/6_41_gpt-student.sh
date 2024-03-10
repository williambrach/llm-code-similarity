
show_help() {
    script_name=$(basename "$0")
    echo "Usage of $script_name:"
    echo ""
    echo "$script_name [-h] [-t <threshold>]"
    echo "Options:"
    echo "  -h  Display this help message."
    echo "  -t  Display users with activity count exceeding <threshold> between 22:00-5:00."
}

help_requested=0
while getopts ":ht:" option; do
    case $option in
    h)
        show_help
        help_requested=1
        ;;
    t)
        threshold=$OPTARG
        if ! [[ $threshold =~ ^[0-9]+$ ]]; then
            echo "Error: <threshold> must be a non-negative integer." >&2
            exit 1
        fi
        ;;
    ?)
        echo "Error: Invalid option provided: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Error: Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
done

analyze_logs() {
    last -f /public/samples/wtmp.2020 | awk -v threshold="${threshold:-0}" '
    BEGIN {
        night_start = "22:00"
        morning_end = "05:00"
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
        if ($7 ~ /:[0-9][0-9]/ && ($7 >= night_start || $7 <= morning_end)) {
            user_activity[$1]++
            month_digit = month_conversion[$5]
            day_digit = sprintf("%02d", $6)
            recent_activity[$1] = month_digit "-" day_digit " " $7
        }
    }
    END {
        for (user in user_activity) {
            if (user_activity[user] > threshold) {
                print "User: " user, user_activity[user], recent_activity[user]
            }
        }
    }'
}

shift $((OPTIND - 1))
if [ "$#" -gt 0 ]; then
    echo "Error: Extra arguments detected: $*" >&2
    exit 1
elif [ $help_requested -eq 1 ]; then
    exit 0
fi
analyze_logs

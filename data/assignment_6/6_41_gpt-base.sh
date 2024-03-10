
display_usage() {
    name_of_script=$(basename "$0")
    echo "How to use $name_of_script:"
    echo ""
    echo "$name_of_script [-h] [-t <limit>]"
    echo "Flags:"
    echo "  -h  Show this help information."
    echo "  -t  Show users with more than <limit> activities from 22:00 to 5:00."
}

request_for_help=0
while getopts ":ht:" opt; do
    case $opt in
    h)
        display_usage
        request_for_help=1
        ;;
    t)
        limit=$OPTARG
        if ! [[ $limit =~ ^[0-9]+$ ]]; then
            echo "Error: <limit> needs to be a positive integer." >&2
            exit 1
        fi
        ;;
    ?)
        echo "Error: Unrecognized option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Error: Missing argument for option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

process_logs() {
    last -f /public/samples/wtmp.2020 | awk -v limit="${limit:-0}" '
    BEGIN {
        start_of_night = "22:00"
        end_of_morning = "05:00"
        month_to_num["Jan"] = "01"
        month_to_num["Feb"] = "02"
        month_to_num["Mar"] = "03"
        month_to_num["Apr"] = "04"
        month_to_num["May"] = "05"
        month_to_num["Jun"] = "06"
        month_to_num["Jul"] = "07"
        month_to_num["Aug"] = "08"
        month_to_num["Sep"] = "09"
        month_to_num["Oct"] = "10"
        month_to_num["Nov"] = "11"
        month_to_num["Dec"] = "12"
    }
    {
        if ($7 ~ /:[0-9][0-9]/ && ($7 >= start_of_night || $7 <= end_of_morning)) {
            activity_count[$1]++
            month_num = month_to_num[$5]
            day_num = sprintf("%02d", $6)
            last_activity[$1] = month_num "-" day_num " " $7
        }
    }
    END {
        for (user in activity_count) {
            if (activity_count[user] > limit) {
                print "User: " user, activity_count[user], last_activity[user]
            }
        }
    }'
}

shift $((OPTIND - 1))
if [ "$#" -gt 0 ]; then
    echo "Error: Unwanted arguments provided: $*" >&2
    exit 1
elif [ $request_for_help -eq 1 ]; then
    exit 0
fi
process_logs

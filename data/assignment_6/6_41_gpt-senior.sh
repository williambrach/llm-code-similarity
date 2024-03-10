
display_usage() {
    prog_name=$(basename "$0")
    echo "Usage of $prog_name:"
    echo ""
    echo "$prog_name [-h] [-t <limit>]"
    echo "Options:"
    echo "  -h  Display this help message."
    echo "  -t  Show user details with entries exceeding <limit> between 22:00-5:00."
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
            echo "Error: <limit> must be a non-negative integer." >&2
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

process_logs() {
    last -f /public/samples/wtmp.2020 | awk -v limit="${limit:-0}" '
    BEGIN {
        evening = "22:00"
        morning = "05:00"
        month_map["Jan"] = "01"
        month_map["Feb"] = "02"
        month_map["Mar"] = "03"
        month_map["Apr"] = "04"
        month_map["May"] = "05"
        month_map["Jun"] = "06"
        month_map["Jul"] = "07"
        month_map["Aug"] = "08"
        month_map["Sep"] = "09"
        month_map["Oct"] = "10"
        month_map["Nov"] = "11"
        month_map["Dec"] = "12"
    }
    {
        if ($7 ~ /:[0-9][0-9]/ && ($7 >= evening || $7 <= morning)) {
            entries_count[$1]++
            month_num = month_map[$5]
            day_num = sprintf("%02d", $6)
            last_entry[$1] = month_num "-" day_num " " $7
        }
    }
    END {
        for (user in entries_count) {
            if (entries_count[user] > limit) {
                print "User: " user, entries_count[user], last_entry[user]
            }
        }
    }'
}

shift $((OPTIND - 1))
if [ "$#" -gt 0 ]; then
    echo "Error: Extra arguments detected: $*" >&2
    exit 1
elif [ $request_for_help -eq 1 ]; then
    exit 0
fi
process_logs

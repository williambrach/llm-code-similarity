script_identifier=$(basename "$0")
creator_name=" "
limit=10
display_help() {
    echo "$script_identifier (C) $creator_name"
    echo ""
    echo "Usage: $script_identifier [-h] [-t <threshold>]"
    echo "  -h: Show this help information"
    echo "  -t <threshold>: Set a custom limit for the number of connections"
}
search_users() {
    last -f /public/samples/wtmp.2020 | awk '{print $1, $3}' | grep -v '^$' | grep -v 'unknown' | grep -v 'reboot' | grep -v 'wtmp' |
        sort | uniq |
        awk -v limit="$limit" '
    {
        if ($2 != "in" && $2 != "console" && $2 != "system" && $2 != "boot") {
            user[$1]++;
            connection[$1,$2]++;
        }
    }
    END {
        for (i in user) {
            total = 0;
            for (j in connection) {
                split(j, arr, SUBSEP);
                if (arr[1] == i) {
                    total++;
                }
            }
            if (total >= limit) {
                print i, total;
            }
        }
    }'
}
if [ $# -eq 0 ]; then
    echo "Error: No parameters given"
    exit 1
fi
while [[ $# -gt 0 ]]; do
    case $1 in
    -h)
        display_help
        shift
        ;;
    -t)
        if [[ $2 =~ ^[0-9]+$ ]]; then
            limit=$2
            search_users
            shift 2
        else
            echo "Error: '$2' is not a valid number"
            exit 1
        fi
        ;;
    *)
        echo "$script_identifier: invalid option -- $1"
        echo "Error: Unrecognized option -"
        shift
        ;;
    esac
done

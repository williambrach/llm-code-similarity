
min_count=10
show_usage() {
    echo "How to use this script"
    echo "Syntax: [-h] [-t] <number> " >&1
    echo "-t <number>	Set the minimum number of IP connections for each user to be shown" >&1
    echo "-t		Show users with a minimum of 10 IP connections" >&1
    echo "-h		Show this help message." >&1
}
aggregate_data() {
    aggregated_data=$(last | awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{print $1, $3}' | sort | uniq -c | sort -nr)
    local threshold=$1
    echo "$aggregated_data" | while read amount username; do
        if [ "$amount" -gt "$threshold" ]; then
            echo "User: '$username' - Connections: '$amount'" >&1
        fi
    done
}
while getopts ":ht:" opt; do
    case $opt in
    h)
        show_usage
        exit 0
        ;;
    t)
        if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            echo "Error: -t option needs a numeric argument" >&2
            exit 1
        fi
        min_count=$OPTARG
        ;;
    ?)
        echo "Error: Invalid option: -$OPTARG." >&2
        exit 1
        ;;
    :)
        echo "Error: Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
done
if [ -z "$min_count" ]; then
    echo "Error: Required argument not provided." >&2
    show_usage
    exit 1
fi
aggregate_data "$min_count"


display_usage() {
    echo "How to use: $0 [-h] [-n <number>]"
    echo "Options:"
    echo " -h        Shows help information"
    echo " -n <number>   Filters users with logins from more than n devices"
}
THRESHOLD=10
DATA_FILE="/public/samples/login_data.2020"
if [ ! -e "$DATA_FILE" ]; then
    echo "Error: 'login_data.2020 file is missing.'"
    exit 1
fi
while [ "$#" -gt 0 ]; do
    case "$1" in
    -n)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            THRESHOLD=$2
        else
            echo "Error: 'The -n option requires a numeric value.'" >&2
            exit 1
        fi
        shift
        ;;
    -h)
        display_usage
        exit 0
        ;;
    *)
        echo "Error: 'Option not recognized.'" >&2
        exit 1
        ;;
    esac
    shift
done
last -f "$DATA_FILE" -w -i | awk '{print $1, $3}' | head -n -2 | grep -v "wtmp begins" | sort | uniq -c | awk -v threshold=$THRESHOLD '{if ($1 > threshold) print "User: \047" $2, $1 "\047"}'
exit 0

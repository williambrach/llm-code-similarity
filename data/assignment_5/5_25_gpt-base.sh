
display_usage() {
    echo "How to use: $0 [-h] [-n <number>]"
    echo "Parameters:"
    echo " -h        Show help information"
    echo " -n <number>   Display users with access from more than <number> devices"
}

DEFAULT_MIN_LOGINS=10
PATH_TO_LOGIN_DATA="/public/samples/login_data.2020"

if [ ! -e "$PATH_TO_LOGIN_DATA" ]; then
    echo "Error: 'login_data.2020 file not found.'"
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
    -n)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            DEFAULT_MIN_LOGINS=$2
        else
            echo "Error: '-n option needs a numeric argument.'" >&2
            exit 1
        fi
        shift 2
        ;;
    -h)
        display_usage
        exit 0
        ;;
    *)
        echo "Error: 'Unknown option provided.'" >&2
        exit 1
        ;;
    esac
done

last -f "$PATH_TO_LOGIN_DATA" -w -i | awk '{print $1, $3}' | head -n -2 | grep -v "wtmp begins" | sort | uniq -c | awk -v min_logins=$DEFAULT_MIN_LOGINS '{if ($1 > min_logins) print "User: \047" $2, $1 "\047"}'
exit 0

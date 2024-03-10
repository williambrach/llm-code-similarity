
show_help() {
    echo "Usage: $0 [-h] [-n <number>]"
    echo "Options:"
    echo " -h        Display this help message"
    echo " -n <number>   Show users with logins from more than <number> devices"
}

MIN_LOGINS=10
LOGIN_DATA_PATH="/public/samples/login_data.2020"

if [ ! -f "$LOGIN_DATA_PATH" ]; then
    echo "Error: 'login_data.2020 file is missing.'"
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
    -n)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            MIN_LOGINS=$2
        else
            echo "Error: 'The -n option requires a numeric value.'" >&2
            exit 1
        fi
        shift 2
        ;;
    -h)
        show_help
        exit 0
        ;;
    *)
        echo "Error: 'Option not recognized.'" >&2
        exit 1
        ;;
    esac
done

last -f "$LOGIN_DATA_PATH" -w -i | awk '{print $1, $3}' | head -n -2 | grep -v "wtmp begins" | sort | uniq -c | awk -v min_logins=$MIN_LOGINS '{if ($1 > min_logins) print "User: \047" $2, $1 "\047"}'
exit 0

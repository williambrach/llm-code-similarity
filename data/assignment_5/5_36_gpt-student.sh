
LOGS_DIR=/public/logs/login_data.2020
min_devices=10
display_help() {
    echo -e "UsageGuide.sh (C)"
    echo ""
    echo "Usage: UsageGuide.sh [-m <number>] [-help]"
    echo "[-m <number>]: display users with logins from more than 'min_devices' devices"
    echo "[-help]: display this help information"
}
while [ "$#" -gt 0 ]; do
    case "$1" in
    -help)
            display_help
            exit 0
            ;;
    -m)
            number_regex='^[0-9]+$'
            shift
            if [[ "$1" =~ $number_regex ]]; then
                    min_devices=$1
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
last -f $LOGS_DIR -w -i | awk '{print $1,$3}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq | awk '{print $1}' | sort | uniq -c | awk -v threshold="$min_devices" '$1>threshold' | sort -nr | awk '{print "User: \047" $2 " - Devices: " $1 "\047"}'

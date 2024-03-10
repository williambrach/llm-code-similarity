
LOG_DIRECTORY=/public/logs/login_data.2020
minimum_devices=10
show_instructions() {
    echo -e "HowToUse.sh (C)"
    echo ""
    echo "Usage: HowToUse.sh [-m <number>] [-help]"
    echo "[-m <number>]: show users with logins from more than 'minimum_devices' devices"
    echo "[-help]: show this help message"
}
while [ "$#" -gt 0 ]; do
    case "$1" in
    -help)
            show_instructions
            exit 0
            ;;
    -m)
            numeric_pattern='^[0-9]+$'
            shift
            if [[ "$1" =~ $numeric_pattern ]]; then
                    minimum_devices=$1
            else
                    echo "Error: 'number not valid'" >&2
                    exit 1
            fi
            ;;
    *)
            echo "Error: 'unknown option'" >&2
            exit 1
            ;;
    esac
    shift
done
last -f $LOG_DIRECTORY -w -i | awk '{print $1,$3}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq | awk '{print $1}' | sort | uniq -c | awk -v limit="$minimum_devices" '$1>limit' | sort -nr | awk '{print "User: \047" $2 " - Devices: " $1 "\047"}'

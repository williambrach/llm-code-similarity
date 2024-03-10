
LOG_FILE_PATH=/public/logs/login.2020
threshold=10
display_help() {
    echo -e "UsageGuide.sh (C)"
    echo ""
    echo "Usage: UsageGuide.sh [-t <number>] [-h]"
    echo "[-t <number>]: display users with logins from more than 'threshold' devices"
    echo "[-h]: display this help information"
}
while [ "$#" -gt 0 ]; do
    case "$1" in
    -h)
            display_help
            exit 0
            ;;
    -t)
            number_pattern='^[0-9]+$'
            shift
            if [[ "$1" =~ $number_pattern ]]; then
                    threshold=$1
            else
                    echo "Error: 'invalid number provided'" >&2
                    exit 1
            fi
            ;;
    *)
            echo "Error: 'unrecognized option'" >&2
            exit 1
            ;;
    esac
    shift
done
last -f $LOG_FILE_PATH -w -i | awk '{print $1,$3}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq | awk '{print $1}' | sort | uniq -c | awk -v t="$threshold" '$1>t' | sort -nr | awk '{print "Outcome: \047" $2,$1 "\047"}'

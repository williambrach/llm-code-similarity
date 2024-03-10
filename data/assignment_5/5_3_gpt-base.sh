
LOGS_DIRECTORY=/public/logs/login.2020
min_count=10
show_instructions() {
    echo -e "ScriptUsage.sh (C)"
    echo ""
    echo "Usage: ScriptUsage.sh [-c <number>] [-help]"
    echo "[-c <number>]: show users with access from more than 'min_count' devices"
    echo "[-help]: show this help message"
}
while [ "$#" -gt 0 ]; do
    case "$1" in
    -help)
            show_instructions
            exit 0
            ;;
    -c)
            numeric_regex='^[0-9]+$'
            shift
            if [[ "$1" =~ $numeric_regex ]]; then
                    min_count=$1
            else
                    echo "Error: 'number provided is not valid'" >&2
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
last -f $LOGS_DIRECTORY -w -i | awk '{print $1,$3}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq | awk '{print $1}' | sort | uniq -c | awk -v c="$min_count" '$1>c' | sort -nr | awk '{print "Result: \047" $2,$1 "\047"}'

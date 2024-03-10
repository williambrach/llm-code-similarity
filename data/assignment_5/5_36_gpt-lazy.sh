LOG_FILE=/public/logs/login_data.2020
count=10
display_help() {
        echo -e "TaskScript.sh (C)"
        echo ""
        echo "Usage: TaskScript.sh [-c <number>] [-h]"
        echo "[-c <number>]: display users who logged in from more than 'count' machines"
        echo "[-h]: display this help message"
}
while (("$#")); do
        case "$1" in
        -h)
                display_help
                exit 0
                ;;
        -c)
                numeric_pattern='^[0-9]+$'
                shift
                if [[ "$1" =~ $numeric_pattern ]]; then
                        count=$1
                else
                        echo "Error: 'invalid argument'" >&2
                        exit 1
                fi
                ;;
        *)
                echo "Error: 'unknown argument'" >&2
                exit 1
                ;;
        esac
        shift
done
last -f $LOG_FILE -w -i | awk '{print $1,$3}' | grep -P '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort | uniq | awk '{print $1}' | sort | uniq -c | awk -v n="$count" '$1>n' | sort -nr | awk '{print "Result: \047" $2,$1 "\047"}'

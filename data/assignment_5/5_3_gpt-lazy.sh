LOGFILE=/public/logs/login.2020
count=10
display_help() {
        echo -e "TaskScript.sh (C)"
        echo ""
        echo "Usage: TaskScript.sh [-c <number>] [-help]"
        echo "[-c <number>]: display users who logged in from more than 'count' machines"
        echo "[-help]: display this help message"
}
while (("$#")); do
        case "$1" in
        -help)
                display_help
                exit 0
                ;;
        -c)
                numeric='^[0-9]+$'
                shift
                if [[ "$1" =~ $numeric ]]; then
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
last -f $LOGFILE -w -i | awk '{print $1,$3}' | grep -P '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort | uniq | awk '{print $1}' | sort | uniq -c | awk -v n="$count" '$1>n' | sort -nr | awk '{print "Result: \047" $2,$1 "\047"}'

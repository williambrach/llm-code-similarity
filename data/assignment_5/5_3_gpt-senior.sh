
ACCESS_LOG=/public/logs/login.2020
limit=10
show_usage() {
    echo -e "UsageGuide.sh (C)"
    echo ""
    echo "Usage: UsageGuide.sh [-l <number>] [-h]"
    echo "[-l <number>]: show users with logins from more than 'limit' devices"
    echo "[-h]: show this usage information"
}
while [ "$#" -gt 0 ]; do
    case "$1" in
    -h)
            show_usage
            exit 0
            ;;
    -l)
            num_regex='^[0-9]+$'
            shift
            if [[ "$1" =~ $num_regex ]]; then
                    limit=$1
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
last -f $ACCESS_LOG -w -i | awk '{print $1,$3}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq | awk '{print $1}' | sort | uniq -c | awk -v m="$limit" '$1>m' | sort -nr | awk '{print "Outcome: \047" $2,$1 "\047"}'

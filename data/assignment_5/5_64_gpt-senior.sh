
typeset -A userIPs # Associative array for mapping users to their IPs

showResults() {
    for user in "${!userIPs[@]}"; do
        ipCount=$(wc -w <<< "${userIPs[$user]}")
        if ((ipCount >= $1)); then
            echo "$user $ipCount"
        fi
    done
}

analyzeLogs() {
    echo "Debug: Processing \"wtmp.2020\" logs (please wait ~30 seconds)"
    while IFS= read -r line; do
        user=$(awk '{print $1}' <<< "$line")
        ip=$(awk '{print $3}' <<< "$line")
        if [[ ${#ip} -lt 4 ]]; then
            continue
        fi
        if [[ -z "${userIPs[$user]}" ]]; then
            userIPs[$user]=$ip
        elif [[ ! "${userIPs[$user]}" =~ $ip ]]; then
            userIPs[$user]+=" $ip"
        fi
    done <<< "$(last -f /public/samples/wtmp.2020 | head -n -1)"
}

if [ $# -eq 0 ]; then
    analyzeLogs
    showResults 10
    exit 0
fi

while (($#)); do
    case $1 in
    -n)
        if [ -n "$2" ] && [[ $2 =~ ^[1-9][0-9]*$ ]]; then
            threshold="$2"
            analyzeLogs
            showResults "$threshold"
            shift
        else
            echo "Error: '$2' is not a valid number" >&2
            exit 1
        fi
        ;;
    -h)
        echo "Usage: $0 -h -n [number]"
        echo "Options:"
        echo "  -h  Show help"
        echo "  -n  Display users with logins from [number] different IPs"
        ;;
    *)
        echo "Error: Invalid option '$1'" >&2
        exit 1
        ;;
    esac
    shift
done

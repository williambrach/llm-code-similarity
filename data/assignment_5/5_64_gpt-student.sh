
declare -A userIPMap # Associative array for mapping users to their IPs

displayUsers() {
    for user in "${!userIPMap[@]}"; do
        ipCount=$(wc -w <<< "${userIPMap[$user]}")
        if ((ipCount >= $1)); then
            echo "$user $ipCount"
        fi
    done
}

processLogData() {
    echo "Debug: Processing \"wtmp.2020\" logs (please wait ~30 seconds)"
    while IFS= read -r line; do
        username=$(awk '{print $1}' <<< "$line")
        ipAddr=$(awk '{print $3}' <<< "$line")
        if [[ ${#ipAddr} -lt 4 ]]; then
            continue
        fi
        if [[ -z "${userIPMap[$username]}" ]]; then
            userIPMap[$username]=$ipAddr
        elif [[ ! "${userIPMap[$username]}" =~ $ipAddr ]]; then
            userIPMap[$username]+=" $ipAddr"
        fi
    done <<< "$(last -f /public/samples/wtmp.2020 | head -n -1)"
}

if [ $# -eq 0 ]; then
    processLogData
    displayUsers 10
    exit 0
fi

while (($#)); do
    case $1 in
    -n)
        if [ -n "$2" ] && [[ $2 =~ ^[1-9][0-9]*$ ]]; then
            minIPs="$2"
            processLogData
            displayUsers "$minIPs"
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

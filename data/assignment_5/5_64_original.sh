
typeset -A ipUserAssoc # Map for associating IPs with users

listUsers() {
    for usr in "${!ipUserAssoc[@]}"; do
        countIPs=$(tr -cd ' ' <<< "${ipUserAssoc[$usr]}" | wc -c)
        let countIPs+=1
        if ((countIPs >= $1)); then
            echo "$usr $countIPs"
        fi
    done
}

analyzeLogEntries() {
    echo "Debug: Analyzing \"wtmp.2020\" log entries (this may take ~30 seconds)"
    while IFS= read -r entry; do
        user=$(cut -d' ' -f1 <<< "$entry")
        ip=$(cut -d' ' -f3 <<< "$entry")
        if [[ ${#ip} -lt 4 ]]; then
            continue
        fi
        if [[ -z "${ipUserAssoc[$user]}" ]]; then
            ipUserAssoc[$user]=$ip
        elif [[ ! "${ipUserAssoc[$user]}" =~ $ip ]]; then
            ipUserAssoc[$user]+=" $ip"
        fi
    done <<< "$(last -f /public/samples/wtmp.2020 | head -n -1)"
}

if [ $# -eq 0 ]; then
    analyzeLogEntries
    listUsers 10
    exit 0
fi

while (($#)); do
    case $1 in
    -n)
        if [ -n "$2" ] && [[ $2 =~ ^[1-9][0-9]*$ ]]; then
            requiredIPs="$2"
            analyzeLogEntries
            listUsers "$requiredIPs"
            shift
        else
            echo "Error: '$2' is not a valid numeric value" >&2
            exit 1
        fi
        ;;
    -h)
        echo "Usage: $0 -h -n [quantity]"
        echo "Options:"
        echo "  -h  Display this help message"
        echo "  -n  Show users with entries from [quantity] distinct IPs"
        ;;
    *)
        echo "Error: Unrecognized option '$1'" >&2
        exit 1
        ;;
    esac
    shift
done

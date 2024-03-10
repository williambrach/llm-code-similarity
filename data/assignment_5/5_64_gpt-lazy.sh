declare -A ipRegistry
displayResults() {
    for account in "${!ipRegistry[@]}"; do
        total=$(echo "${ipRegistry[$account]}" | awk '{print NF}')
        if ((total >= "$1")); then
            echo "$account $total"
        fi
    done
}
parseLogs() {
    echo "Debug: Analyzing \"wtmp.2020\" logs (takes about 30 seconds)"
    while read -r entry; do
        local account
        account=$(echo "$entry" | awk '{print $1}')
        local ipAddr
        ipAddr=$(echo "$entry" | awk '{print $3}')
        if [[ ${#ipAddr} -lt 4 ]]; then
            continue
        fi
        if [[ -z "${ipRegistry[$account]}" ]]; then
            ipRegistry[$account]=$ipAddr
        elif [[ ! "${ipRegistry[$account]}" =~ $ipAddr ]]; then
            ipRegistry[$account]+=" $ipAddr"
        fi
    done <<<"$(last -f /public/samples/wtmp.2020 | sed '$d')"
}
if [ "$#" == "0" ]; then
    parseLogs
    displayResults 10
    exit 0
fi
while (("$#")); do
    case "$1" in
    -n)
        if [[ -n "$2" ]]; then
            if [[ "$2" =~ ^[1-9][0-9]*$ ]]; then
                num="$2"
                parseLogs
                displayResults "$num"
                shift
            else
                echo "$0: '$2': Is not a number" 1>&2
                exit 1
            fi
        else
            echo "$0: '$1': Next argument is required" 1>&2
        fi
        ;;
    -h)
        echo "$0 (C)"
        echo ""
        echo "Usage: $0 -h -n 4"
        echo -e "\t-h:\tDisplays command information"
        echo -e "\t-n:\tDetermines which users logged in from n different machines"
        echo -e "\t 4:\tThe number following '-n' indicating the specific number of machines, in this case 4"
        ;;
    -* | *)
        echo "$0: '$1': Unexpected argument" 1>&2
        exit 1
        ;;
    esac
    shift
done

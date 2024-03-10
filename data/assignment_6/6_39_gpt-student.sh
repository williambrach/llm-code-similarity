
logFilePath="/public/data/login_records.2020"
minLogins=0
nightLoginOption=0
scriptAuthor=" "
if [[ -n $LOGIN_FILE_OVERRIDE ]]; then
    logFilePath="$LOGIN_FILE_OVERRIDE"
fi
if [[ ! -f $logFilePath ]]; then
    echo "Error: '$logFilePath' does not exist." >&2
    exit 1
fi
showHelp() {
    echo "$0 © $scriptAuthor"
    echo ""
    echo "Usage: $0 [-h] [-n <number>]"
    echo "  -h: Display this help message."
    echo "  -n <number>: Filter users with night logins more than <number>."
    echo "  LOGIN_FILE_OVERRIDE=<path>: Specify a custom login file path."
    exit 0
}
validateNumber() {
    [[ $1 =~ ^-?[0-9]+$ ]]
}
handleArgs() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n)
                if [[ $nightLoginOption -eq 1 ]]; then
                    echo "Error: Option '-n' can only be used once." >&2
                    exit 1
                fi
                nightLoginOption=1
                if validateNumber "$2"; then
                    minLogins="$2"
                    shift 2
                else
                    if [[ -z "$2" ]]; then
                        echo "Error: '-n' requires a numeric value." >&2
                    else
                        echo "Error: '-n' received an invalid value: '$2'." >&2
                    fi
                    exit 1
                fi
                ;;
            -h)
                showHelp
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                exit 1
                ;;
        esac
    done
}
handleArgs "$@"
filteredLog=$(last -f "$logFilePath" | awk '$NF ~ /^\([-]*[0-9]*[+]*[0-9][0-9]:[0-5][0-9]\)$/ && NF == 10 { $3 = ""; print }' | awk '{time = $6} time >= "22:00" || time <= "05:00"' | sort -k4M -k5n -k6)
declare -A loginStats lastLoginTime lastLoginDate
while IFS= read -r entry; do
    read -r user _ _ month day time _ <<< "$entry"
    loginStats["$user"]=$((${loginStats["$user"]} + 1))
    lastLoginDate["$user"]=$(date -d "$month $day" +%m-%d)
    lastLoginTime["$user"]=$time
done <<< "$filteredLog"
for user in "${!loginStats[@]}"; do
    if [[ ${loginStats[$user]} -gt $minLogins ]]; then
        printf "User: '%s' Logins: %s Last: %s %s\n" "$user" "${loginStats[$user]}" "${lastLoginDate[$user]}" "${lastLoginTime[$user]}"
    fi
done

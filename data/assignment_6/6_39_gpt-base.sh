
loginDataPath="/public/data/login_records.2020"
minimumLoginsRequired=0
filterNightLogins=0
authorName=" "
if [[ -n $CUSTOM_LOGIN_FILE_PATH ]]; then
    loginDataPath="$CUSTOM_LOGIN_FILE_PATH"
fi
if [[ ! -e $loginDataPath ]]; then
    echo "Error: File '$loginDataPath' not found." >&2
    exit 1
fi
displayUsage() {
    echo "Script by $authorName"
    echo ""
    echo "How to use: $0 [-h] [-n <value>]"
    echo "  -h: Show help."
    echo "  -n <value>: Show users with more than <value> night logins."
    echo "  CUSTOM_LOGIN_FILE_PATH=<path>: Set a different login file path."
    exit 0
}
isNumeric() {
    [[ $1 =~ ^-?[0-9]+$ ]]
}
processArguments() {
    while [ $# -gt 0 ]; do
        case $1 in
            -n)
                if [ $filterNightLogins -eq 1 ]; then
                    echo "Error: '-n' can only be specified once." >&2
                    exit 1
                fi
                filterNightLogins=1
                if isNumeric "$2"; then
                    minimumLoginsRequired="$2"
                    shift 2
                else
                    if [ -z "$2" ]; then
                        echo "Error: '-n' needs a number." >&2
                    else
                        echo "Error: '-n' got an invalid number: '$2'." >&2
                    fi
                    exit 1
                fi
                ;;
            -h)
                displayUsage
                ;;
            *)
                echo "Error: Unrecognized option '$1'" >&2
                exit 1
                ;;
        esac
    done
}
processArguments "$@"
logAnalysis=$(last -f "$loginDataPath" | awk '$NF ~ /^\([-]*[0-9]*[+]*[0-9][0-9]:[0-5][0-9]\)$/ && NF == 10 { $3 = ""; print }' | awk '{time = $6} time >= "22:00" || time <= "05:00"' | sort -k4M -k5n -k6)
declare -A userLoginCount lastTime lastDate
while IFS= read -r line; do
    read -r username _ _ month day time _ <<< "$line"
    userLoginCount["$username"]=$((${userLoginCount["$username"]} + 1))
    lastDate["$username"]=$(date -d "$month $day" +%m-%d)
    lastTime["$username"]=$time
done <<< "$logAnalysis"
for username in "${!userLoginCount[@]}"; do
    if [[ ${userLoginCount[$username]} -gt $minimumLoginsRequired ]]; then
        printf "User: '%s', Logins: %s, Last login: %s %s\n" "$username" "${userLoginCount[$username]}" "${lastDate[$username]}" "${lastTime[$username]}"
    fi
done

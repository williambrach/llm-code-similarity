
login_data_path="/public/data/login_records.2020"
minimum_logins_required=0
night_login_flag=0
author=" "
if [[ -n $LOGIN_FILE_OVERRIDE ]]; then
    login_data_path="$LOGIN_FILE_OVERRIDE"
fi
if [[ ! -e $login_data_path ]]; then
    echo "Error: '$login_data_path' does not exist." >&2
    exit 1
fi
display_help() {
    echo "$0 © $author"
    echo ""
    echo "How to use: $0 [-h] [-n <number>]"
    echo "  -h: Show help."
    echo "  -n <number>: Show users with night logins exceeding the specified number."
    echo "  LOGIN_FILE_OVERRIDE=<path>: Use a custom login file path instead of the default."
    exit 0
}
is_numeric() {
    [[ $1 =~ ^-?[0-9]+$ ]]
}
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n)
                if [[ $night_login_flag -eq 1 ]]; then
                    echo "Error: Option '-n' can only be used once." >&2
                    exit 1
                fi
                night_login_flag=1
                if is_numeric "$2"; then
                    minimum_logins_required="$2"
                    shift 2
                else
                    if [[ -z "$2" ]]; then
                        echo "Error: '-n' needs a numeric value." >&2
                    else
                        echo "Error: '-n' got an invalid value: '$2'." >&2
                    fi
                    exit 1
                fi
                ;;
            -h)
                display_help
                ;;
            *)
                echo "Error: Invalid option '$1'" >&2
                exit 1
                ;;
        esac
    done
}
parse_arguments "$@"
processed_log=$(last -f "$login_data_path" | awk '$NF ~ /^\([-]*[0-9]*[+]*[0-9][0-9]:[0-5][0-9]\)$/ && NF == 10 { $3 = ""; print }' | awk '{time = $6} time >= "22:00" || time <= "05:00"' | sort -k4M -k5n -k6)
declare -A login_count last_time last_date
while IFS= read -r line; do
    read -r user _ _ month day time _ <<< "$line"
    login_count["$user"]=$((${login_count["$user"]} + 1))
    last_date["$user"]=$(date -d "$month $day" +%m-%d)
    last_time["$user"]=$time
done <<< "$processed_log"
for user in "${!login_count[@]}"; do
    if [[ ${login_count[$user]} -gt $minimum_logins_required ]]; then
        printf "User: '%s' Logins: %s Last: %s %s\n" "$user" "${login_count[$user]}" "${last_date[$user]}" "${last_time[$user]}"
    fi
done

log_path="/public/data/login_records.2020"
min_logins=0 # minimum number of logins for the -n option
n_flag=0     # helper variable for input check
creator=" "
if [ -n "$LOGIN_FILE_OVERRIDE" ]; then # check if a file path was provided as input, if so, overwrite the default path
    log_path="$LOGIN_FILE_OVERRIDE"
fi
if [ ! -f "$log_path" ]; then # check if the file exists
    echo "Error: '$log_path': the specified file does not exist." >&2
    exit 1
fi
show_usage() {
    echo "$0 (C) $creator"
    echo ""
    echo "Usage: $0 [-h] [-n <number>]"
    echo "  -h: displays help information about how to use the script."
    echo "  -n <number>: displays users who logged in at night more times than the specified value."
    echo "  LOGIN_FILE_OVERRIDE=<path-to-file>: sets a custom file path (changes the default path)."
    exit 0
}
validate_integer() {
    [[ $1 =~ ^[0-9]+$ ]]
}
while [[ "$#" -gt 0 ]]; do
    case "$1" in
    -n)
        if [ $n_flag -ne 0 ]; then # check if the -n option was already provided, if so, print an error
            echo "Error: '-n': this option can only be specified once." >&2
            exit 1
        fi
        n_flag=1 # helper variable

        if validate_integer "$2"; then # if the -n option was followed by a valid value
            min_logins="$2"            # store the provided value in min_logins
            shift 2                    # move the parameter position by 2
        else                           # if the -n option was followed by an invalid value
            if [ -z "$2" ]; then       # if no value was provided, print an error and exit
                echo "Error: '-n': requires a numeric argument." >&2
            else # if an invalid value was provided, print an error and exit
                echo "Error: '-n': invalid argument, '$2' is not a valid argument." >&2
            fi
            exit 1
        fi
        ;;
    -h)
        show_usage # if the -h option was provided, call the show_usage function and exit
        ;;
    *) # if an invalid option was provided, print an error and exit
        echo "Error: '$1': invalid option" >&2
        exit 1
        ;;
    esac
done
last_output=$(last -f "$log_path" | awk '$NF ~ /^\([-]*[0-9]*[+]*[0-9][0-9]:[0-5][0-9]\)$/ && NF == 10 { $3 = ""; print }' | awk '{time = $6} time >= "22:00" || time <= "05:00"' | sort -k4M -k5n -k6)
declare -A user_count last_login_time last_login_date
while read -r username _ _ month day time _ _ _; do
    user_count["$username"]=$((user_count["$username"] + 1))
    last_login_date["$username"]=$(date -d "$month $day" +%m-%d)
    last_login_time["$username"]=$time
done <<<"$last_output"
for username in "${!user_count[@]}"; do
    if [ "${user_count[$username]}" -gt "$min_logins" ]; then
        printf "%s %s %s %s\n" "Output: '$username" "${user_count[$username]}" "${last_login_date[$username]}" "${last_login_time[$username]}'"
    fi
done

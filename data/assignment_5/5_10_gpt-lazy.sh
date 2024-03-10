exec 2>error_output.log
count=10
total_args=$#
if [ -e helper_file ]; then
    data_file=$(cat helper_file)
else
    data_file="/public/samples/wtmp.2021"
fi
index=1
while [ $index -le $total_args ]; do
    case "${!index}" in
    -n)
        if [ $index -lt $total_args ]; then
            next_index="${index+1}"
            if [[ $next_index =~ ^[0-9]+$ ]]; then
                ((total_args--))
            fi
        fi
        ;;
    esac
    ((index++))
done
if [ $total_args -ge 3 ]; then
    printf "Error: '%s': Too many arguments.\n" "$0"
    exit 1
fi
while [[ $# -gt 0 ]]; do
    case "$1" in
    -n)
        shift
        if [[ $# -gt 0 ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
            count="$1"
        else
            printf "Error: '%s': Missing value for -n option.\n" "$0"
            exit 1
        fi
        ;;
    -h)
        echo "$0 (C) Jakub Horvath"
        echo
        usage="Usage: $0 $*"
        if [ "$count" ]; then
            usage="${usage/-n [0-9]*/-n}"
        fi
        echo "$usage"
        for ((index = 1; index <= $#; index++)); do
            if [ "${!index}" == "-n" ]; then
                arg_name="${!index}"
                ((index++))
                arg_value="specifies the number of logged-in machines"
                echo "$arg_name: $arg_value"
            fi
            if [ "${!index}" == "-h" ]; then
                arg_name="${!index}"
                arg_value="launches script helpers"
                echo "$arg_name: $arg_value"
            fi
        done
        exit 0
        ;;
    *)
        printf "Error: '%s': Unknown option %s.\n" "$0" "$1"
        exit 1
        ;;
    esac
    shift
done
last -f "$data_file" | awk -v n="$count" '{
    if ($3 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
        users[$1]++;
    }
} 
END {
    for (user in users) {
        if (users[user] > n) {
            printf "Output: '\''%s %d'\''\n", user, users[user];
        }
    }
}' 2>&1

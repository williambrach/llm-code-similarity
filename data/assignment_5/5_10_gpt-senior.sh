
#!/bin/bash

# Redirect standard error to a log file
exec 2>err_log.txt

# Default count value
num=10

# Check if helper_file exists and read its content into data_file variable
if [ -f helper_file ]; then
    data_file="$(<helper_file)"
else
    data_file="/public/samples/wtmp.2021"
fi

# Process script arguments
arg_count="$#"
i=1
while [ $i -le $arg_count ]; do
    case "${!i}" in
    -n)
        if [ $i -lt $arg_count ]; then
            next_i=$((i + 1))
            if [[ "${!next_i}" =~ ^[0-9]+$ ]]; then
                ((arg_count--))
            fi
        fi
        ;;
    esac
    ((i++))
done

# Check for excessive arguments
if [ $arg_count -ge 3 ]; then
    printf "Error: '%s': Excessive arguments provided.\n" "$0" >&2
    exit 1
fi

# Parse options
while [ $# -gt 0 ]; do
    case "$1" in
    -n)
        shift
        if [[ $# -gt 0 ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
            num="$1"
        else
            printf "Error: '%s': -n requires a numeric argument.\n" "$0" >&2
            exit 1
        fi
        ;;
    -h)
        echo "Copyright (C) Jakub Horvath"
        echo
        usage_str="Usage: $0 $*"
        if [ "$num" ]; then
            usage_str="${usage_str/-n [0-9]*/-n}"
        fi
        echo "$usage_str"
        for ((i = 1; i <= $#; i++)); do
            case "${!i}" in
            -n)
                echo "-n: number of logged-in machines to report"
                ((i++))
                ;;
            -h)
                echo "-h: display this help and exit"
                ;;
            esac
        done
        exit 0
        ;;
    *)
        printf "Error: '%s': Invalid option '%s'.\n" "$0" "$1" >&2
        exit 1
        ;;
    esac
    shift
done

# Process the data file and output results
awk -v cnt="$num" '{
    if ($3 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
        logins[$1]++;
    }
}
END {
    for (user in logins) {
        if (logins[user] > cnt) {
            printf "Result: '\''%s %d'\''\n", user, logins[user];
        }
    }
}' "$data_file" 2>&1

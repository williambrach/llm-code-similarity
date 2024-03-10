
#!/bin/bash

# Redirect standard error to a log file
exec 2>error_log.txt

# Set default report count
report_count=10

# Determine the data source file
if [ -f helper_file ]; then
    source_file="$(<helper_file)"
else
    source_file="/public/samples/wtmp.2021"
fi

# Pre-process script arguments to adjust for -n option
total_args="$#"
arg_index=1
while [ $arg_index -le $total_args ]; do
    case "${!arg_index}" in
    -n)
        if [ $arg_index -lt $total_args ]; then
            next_arg=$((arg_index + 1))
            if [[ "${!next_arg}" =~ ^[0-9]+$ ]]; then
                ((total_args--))
            fi
        fi
        ;;
    esac
    ((arg_index++))
done

# Validate argument count
if [ $total_args -ge 3 ]; then
    printf "Error: '%s': Too many arguments.\n" "$0" >&2
    exit 1
fi

# Process command-line options
while [ $# -gt 0 ]; do
    case "$1" in
    -n)
        shift
        if [[ $# -gt 0 ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
            report_count="$1"
        else
            printf "Error: '%s': The -n option requires a numeric argument.\n" "$0" >&2
            exit 1
        fi
        ;;
    -h)
        echo "Copyright (C) Jakub Horvath"
        echo
        help_message="Usage: $0 $*"
        if [ "$report_count" ]; then
            help_message="${help_message/-n [0-9]*/-n}"
        fi
        echo "$help_message"
        for ((arg_index = 1; arg_index <= $#; arg_index++)); do
            case "${!arg_index}" in
            -n)
                echo "-n: specify the number of logged-in machines to report"
                ((arg_index++))
                ;;
            -h)
                echo "-h: display help information and exit"
                ;;
            esac
        done
        exit 0
        ;;
    *)
        printf "Error: '%s': Unrecognized option '%s'.\n" "$0" "$1" >&2
        exit 1
        ;;
    esac
    shift
done

# Analyze the data file and display results
awk -v count="$report_count" '{
    if ($3 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
        login_counts[$1]++;
    }
}
END {
    for (user in login_counts) {
        if (login_counts[user] > count) {
            printf "Result: '\''%s %d'\''\n", user, login_counts[user];
        }
    }
}' "$source_file" 2>&1

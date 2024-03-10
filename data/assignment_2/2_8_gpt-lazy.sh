usage_info="$0 (C)
How to use: $0 [-h] [directory ...]
	[-h]: shows this help message
	[directory ...]: directories or files to process"
dir_paths=()
accept_stdin=false
if [ "$#" -eq "0" ]; then
    accept_stdin=true
else
    while [[ "$#" -gt "0" ]]; do
        case $1 in
        -h)
            echo "$usage_info"
            exit 0
            ;;
        *)
            if [[ -f $1 ]]; then
                dir_paths+=("$1")
            else
                printf "Error: '%s' does not point to a valid file\n" "$1" 1>&2
                exit 1
            fi
            shift
            ;;
        esac
    done
fi
if $accept_stdin; then
    dir_paths+=('-')
fi
for path in "${dir_paths[@]}"; do
    longest_length=0
    longest_lines=()
    line_numbers=()
    if [ "$path" == "-" ]; then
        source_input=/dev/stdin
    else
        source_input=$path
    fi
    line_counter=0
    while IFS= read -r line || [ -n "$line" ]; do
        line=${line//$'\r'/}
        ((line_counter++))
        line_length=${#line}
        if [ "$line_length" -ge "$longest_length" ]; then
            if [ "$line_length" -gt "$longest_length" ]; then
                longest_lines=()
                line_numbers=()
                longest_length=$line_length
            fi
            longest_lines+=("$line")
            line_numbers+=("$line_counter")
        fi
    done <"$source_input"
    for ((idx = 0; idx < ${#longest_lines[@]}; idx++)); do
        echo "Result: '$path: ${line_numbers[$idx]} $longest_length ${longest_lines[$idx]}'"
    done
done
exit 0

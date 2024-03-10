
#!/bin/bash

# Helper message
help_msg="How to use: $0 [-h] [file ...]
-h: Show help.
[file ...]: Files to process. Defaults to stdin if none specified."

# List to hold file names
file_list=()
# Boolean for reading from stdin
read_from_stdin=false

# If no arguments, read from stdin
if [ $# -eq 0 ]; then
    read_from_stdin=true
else
    # Loop through all arguments
    for arg in "$@"; do
        case $arg in
        -h)
            echo "$help_msg"
            exit 0
            ;;
        *)
            if [ -e "$arg" ]; then
                file_list+=("$arg")
            else
                echo "Error: Invalid file '$arg'" >&2
                exit 1
            fi
            ;;
        esac
        shift
    done
fi

# If reading from stdin, add it to the list
if $read_from_stdin; then
    file_list+=('/dev/stdin')
fi

# Process each specified file
for file in "${file_list[@]}"; do
    max_len=0
    max_lines=()
    nums=()
    file_name=$file
    line_num=0
    while IFS= read -r line || [[ -n $line ]]; do
        # Clean up carriage returns
        line=${line%$'\r'}
        ((line_num++))
        len=${#line}
        if [[ $len -ge $max_len ]]; then
            if [[ $len -gt $max_len ]]; then
                max_lines=()
                nums=()
                max_len=$len
            fi
            max_lines+=("$line")
            nums+=("$line_num")
        fi
    done <"$file_name"
    for i in "${!max_lines[@]}"; do
        echo "Max: '$file_name: ${nums[$i]} $max_len ${max_lines[$i]}'"
    done
done
exit 0

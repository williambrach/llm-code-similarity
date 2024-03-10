
#!/bin/bash

# Display usage instructions
usage="Usage: $0 [-h] [file ...]
Options:
    -h: Display this help message.
    [file ...]: Specify files to analyze. Reads from stdin if no file is provided."

# Initialize an array to store file paths
paths=()
# Flag to indicate if stdin should be used
use_stdin=false

# Check if no arguments were provided
if [ "$#" -eq "0" ]; then
    use_stdin=true
else
    # Process command line arguments
    while [ "$#" -gt "0" ]; do
        case "$1" in
        -h)
            echo "$usage"
            exit 0
            ;;
        *)
            if [ -f "$1" ]; then
                paths+=("$1")
            else
                echo "Error: '$1' is not a valid file" >&2
                exit 1
            fi
            shift
            ;;
        esac
    done
fi

# Add stdin to paths if required
if $use_stdin; then
    paths+=('/dev/stdin')
fi

# Analyze each file
for path in "${paths[@]}"; do
    longest_length=0
    longest_lines=()
    line_numbers=()
    source_file=$path
    count=0
    while IFS= read -r line || [ -n "$line" ]; do
        # Remove carriage return characters
        line=${line//$'\r'/}
        ((count++))
        length=${#line}
        if [ "$length" -ge "$longest_length" ]; then
            if [ "$length" -gt "$longest_length" ]; then
                longest_lines=()
                line_numbers=()
                longest_length=$length
            fi
            longest_lines+=("$line")
            line_numbers+=("$count")
        fi
    done <"$source_file"
    for ((i = 0; i < ${#longest_lines[@]}; i++)); do
        echo "Longest: '$path: ${line_numbers[$i]} $longest_length ${longest_lines[$i]}'"
    done
done
exit 0

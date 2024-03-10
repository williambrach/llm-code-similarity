
#!/bin/bash

# Display usage instructions
show_help="Usage: $0 [-h] [file ...]
Options:
	-h: Display this help message.
	[file ...]: Specify files to analyze. Reads from stdin if no file is provided."

# Initialize an array to store file paths
file_list=()
# Flag to indicate if stdin should be used
read_from_stdin=false

# Check if no arguments were provided
if [ "$#" -eq "0" ]; then
    read_from_stdin=true
else
    # Process command line arguments
    while [ "$#" -gt "0" ]; do
        case "$1" in
        -h)
            echo "$show_help"
            exit 0
            ;;
        *)
            if [ -f "$1" ]; then
                file_list+=("$1")
            else
                echo "Error: '$1' is not a valid file" >&2
                exit 1
            fi
            shift
            ;;
        esac
    done
fi

# Add stdin to file list if required
if $read_from_stdin; then
    file_list+=('/dev/stdin')
fi

# Process each file in the list
for file in "${file_list[@]}"; do
    max_length=0
    max_lines=()
    line_nums=()
    input_source=$file
    line_count=0
    while IFS= read -r line || [ -n "$line" ]; do
        # Remove carriage return characters
        line=${line//$'\r'/}
        ((line_count++))
        len=${#line}
        if [ "$len" -ge "$max_length" ]; then
            if [ "$len" -gt "$max_length" ]; then
                max_lines=()
                line_nums=()
                max_length=$len
            fi
            max_lines+=("$line")
            line_nums+=("$line_count")
        fi
    done <"$input_source"
    for ((i = 0; i < ${#max_lines[@]}; i++)); do
        echo "Longest: '$file: ${line_nums[$i]} $max_length ${max_lines[$i]}'"
    done
done
exit 0

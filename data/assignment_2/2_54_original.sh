
#!/bin/bash

# Identifies the lines with the maximum length
search_max_length_lines() {
    local current_line length_of_line
    local -n lines_max_length=max_length_lines length_max=max_length line_positions=positions
    max_length=0
    local position=0
    while IFS= read -r current_line || [[ -n "$current_line" ]]; do
        ((position++))
        length_of_line=${#current_line}
        if (( length_of_line > max_length )); then
            max_length=$length_of_line
            lines_max_length=("$current_line")
            line_positions=("$position")
        elif (( length_of_line == max_length )); then
            lines_max_length+=("$current_line")
            line_positions+=("$position")
        fi
    done
}

# Displays the lines with the maximum length and their details
display_max_length_lines() {
    local -n max_lines=max_length_lines positions=line_positions prefixes=prefix_files
    for i in "${!max_lines[@]}"; do
        echo "Max Length: '${prefixes[$i]}: ${positions[$i]} ${#max_lines[$i]} ${max_lines[$i]}'"
    done
}

# Main logic of the script
if [ "$#" -eq 0 ]; then
    input_from_stdin=true
elif [ "$1" = "-h" ]; then
    echo "Usage: $0 [-h] [path_to_file ...]"
    echo -e "\t-h: Display this help message."
    echo -e "\tfile_path: Specify file(s) or directory(ies) path."
    exit 0
else
    input_from_stdin=false
fi

if $input_from_stdin; then
    max_length_lines=()
    max_length=0
    line_positions=()
    search_max_length_lines max_length_lines max_length line_positions
    display_max_length_lines max_length_lines line_positions max_length_lines
else
    while [ "$#" -gt 0 ]; do
        if [ -f "$1" ]; then
            max_length_lines=()
            max_length=0
            line_positions=()
            while IFS= read -r line; do
                search_max_length_lines max_length_lines max_length line_positions
            done < "$1"
            prefix_files=("$1")
            display_max_length_lines max_length_lines line_positions prefix_files
        elif [ -d "$1" ]; then
            readarray -t file_list < <(find "$1" -type f)
            for file in "${file_list[@]}"; do
                max_length_lines=()
                max_length=0
                line_positions=()
                while IFS= read -r line; do
                    search_max_length_lines max_length_lines max_length line_positions
                done < "$file"
                prefix_files=("$file")
                display_max_length_lines max_length_lines line_positions prefix_files
            done
        else
            echo "Error: '$1' is not a valid input." >&2
            exit 1
        fi
        shift
    done
fi

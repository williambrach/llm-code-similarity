
#!/bin/bash

# Function to process lines
process_lines() {
    local line line_length
    local -n _longest_lines=_1 _longest_length=_2 _line_numbers=_3
    _longest_length=0
    local line_number=0
    while IFS= read -r line || [ -n "$line" ]; do
        ((line_number++))
        line_length=${#line}
        if (( line_length > _longest_length )); then
            _longest_length=$line_length
            _longest_lines=("$line")
            _line_numbers=("$line_number")
        elif (( line_length == _longest_length )); then
            _longest_lines+=("$line")
            _line_numbers+=("$line_number")
        fi
    done
}

# Function to display results
display_results() {
    local -n _lines=_1 _numbers=_2 _prefixes=_3
    for i in "${!_lines[@]}"; do
        echo "Result: '${_prefixes[$i]}: ${_numbers[$i]} ${#_lines[$i]} ${_lines[$i]}'"
    done
}

# Main script starts here
if [ "$#" -eq 0 ]; then
    read_from_stdin=true
elif [ "$1" = "-h" ]; then
    echo "Usage: $0 [-h] [file_path ...]"
    echo -e "\t-h: Show help."
    echo -e "\tfile_path: Path to file(s) or directory(ies)."
    exit 0
else
    read_from_stdin=false
fi

if $read_from_stdin; then
    longest_lines=()
    longest_length=0
    line_numbers=()
    process_lines longest_lines longest_length line_numbers
    display_results longest_lines line_numbers longest_lines
else
    while [ "$#" -gt 0 ]; do
        if [ -f "$1" ]; then
            longest_lines=()
            longest_length=0
            line_numbers=()
            while IFS= read -r line; do
                process_lines longest_lines longest_length line_numbers
            done < "$1"
            file_prefixes=("$1")
            display_results longest_lines line_numbers file_prefixes
        elif [ -d "$1" ]; then
            readarray -t files < <(find "$1" -type f)
            for file in "${files[@]}"; do
                longest_lines=()
                longest_length=0
                line_numbers=()
                while IFS= read -r line; do
                    process_lines longest_lines longest_length line_numbers
                done < "$file"
                file_prefixes=("$file")
                display_results longest_lines line_numbers file_prefixes
            done
        else
            echo "Error: '$1' is not valid." >&2
            exit 1
        fi
        shift
    done
fi

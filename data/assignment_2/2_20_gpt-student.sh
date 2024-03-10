
display_usage() {
    echo "$0 (C)"
    echo ""
    echo "Usage: $0 -h file_path ..."
    echo -e "\t-h: Display this help message."
    echo -e "\t file_path: Path to the file for processing."
}

identify_longest_line() {
    longest_line_length=$(awk 'BEGIN{longest=0} longest<length{longest=length} END{print longest}' temp_file.txt)
    awk -v longest="$longest_line_length" -v prefix="*" 'longest == length {gsub("\r", ""); printf "Longest: '\''%s: %d %d %s'\''\n", prefix, NR, length, $0 }' temp_file.txt
}

handle_input() {
    >temp_file.txt # Create or clear the file
    num_lines=0
    while IFS= read -r line; do
        echo "$line" >>temp_file.txt
        ((num_lines++))
    done
    if [ "$num_lines" -gt 0 ]; then
        identify_longest_line
        rm temp_file.txt
        exit 0
    else
        echo "Error: '*': No input provided" >&2
        exit 1
    fi
}

if [ $# -eq 0 ]; then
    handle_input
else
    input_files=()
    for arg in "$@"; do
        if [ "$arg" == "-h" ]; then
            display_usage
            exit 0
        elif [[ "$arg" == -* ]]; then
            echo "Error: '*': Unknown option $arg" >&2
            exit 1
        else
            input_files+=("$arg")
        fi
    done
    exit_code=0
    for file in "${input_files[@]}"; do
        if [ -e "$file" ]; then
            if [ -f "$file" ] && [ -r "$file" ]; then
                if file "$file" | grep -q "text"; then
                    continue
                else
                    echo "Error: '$file': Invalid text file or empty" >&2
                    exit_code=1
                    input_files=("${input_files[@]/$file}")
                fi
            else
                echo "Error: '$file': Not a file or unreadable" >&2
                exit_code=1
                input_files=("${input_files[@]/$file}")
            fi
        else
            echo "Error: '$file': File does not exist" >&2
            exit_code=1
            input_files=("${input_files[@]/$file}")
        fi
    done
    if [ ${#input_files[@]} -eq 0 ]; then
        exit 1
    fi
    longest_line_length=$(awk 'BEGIN{longest=0} longest<length{longest=length} END{print longest}' "${input_files[@]}")
    for file in "${input_files[@]}"; do
        awk -v longest="$longest_line_length" -v prefix="$file" 'longest == length {gsub("\r", ""); printf "Longest: '\''%s: %d %d %s'\''\n", prefix, NR, length, $0 }' "$file"
    done
fi
exit $exit_code

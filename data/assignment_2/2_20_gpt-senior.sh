
show_help() {
    echo "$0 (C)"
    echo ""
    echo "Usage: $0 -h path_to_file ..."
    echo -e "\t-h: Show this help message."
    echo -e "\t path_to_file: Specify the file path for operation."
}
find_longest_line() {
    max_length=$(awk 'BEGIN{max=0} max<length{max=length} END{print max}' temp_file.txt)
    awk -v maxlen="$max_length" -v prefix="*" 'maxlen == length {gsub("\r", ""); printf "Longest: '\''%s: %d %d %s'\''\n", prefix, NR, length, $0 }' temp_file.txt
}
process_input() {
    >temp_file.txt # Create or clear the file
    line_count=0
    while IFS= read -r line; do
        echo "$line" >>temp_file.txt
        ((line_count++))
    done
    if [ "$line_count" -gt 0 ]; then
        find_longest_line
        rm temp_file.txt
        exit 0
    else
        echo "Error: '*': No input given" >&2
        exit 1
    fi
}
if [ $# -eq 0 ]; then
    process_input
else
    file_paths=()
    for param in "$@"; do
        if [ "$param" == "-h" ]; then
            show_help
            exit 0
        elif [[ "$param" == -* ]]; then
            echo "Error: '*': Unknown option $param" >&2
            exit 1
        else
            file_paths+=("$param")
        fi
    done
    status_code=0
    for file_path in "${file_paths[@]}"; do
        if [ -e "$file_path" ]; then
            if [ -f "$file_path" ] && [ -r "$file_path" ]; then
                if file "$file_path" | grep -q "text"; then
                    continue
                else
                    echo "Error: '$file_path': Not a valid text file or is empty" >&2
                    status_code=1
                    file_paths=("${file_paths[@]/$file_path}")
                fi
            else
                echo "Error: '$file_path': Not a file or unreadable" >&2
                status_code=1
                file_paths=("${file_paths[@]/$file_path}")
            fi
        else
            echo "Error: '$file_path': File does not exist" >&2
            status_code=1
            file_paths=("${file_paths[@]/$file_path}")
        fi
    done
    if [ ${#file_paths[@]} -eq 0 ]; then
        exit 1
    fi
    max_length=$(awk 'BEGIN{max=0} max<length{max=length} END{print max}' "${file_paths[@]}")
    for file_path in "${file_paths[@]}"; do
        awk -v maxlen="$max_length" -v prefix="$file_path" 'maxlen == length {gsub("\r", ""); printf "Longest: '\''%s: %d %d %s'\''\n", prefix, NR, length, $0 }' "$file_path"
    done
fi
exit $status_code

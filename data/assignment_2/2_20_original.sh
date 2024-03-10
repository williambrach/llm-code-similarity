
show_help() {
    echo "Script: $0 (C)"
    echo ""
    echo "How to use: $0 -h target_file ..."
    echo -e "\t-h: Shows help information."
    echo -e "\t target_file: Specifies the file to be processed."
}

find_longest_line() {
    max_length=$(awk 'BEGIN{max=0} max<length{max=length} END{print max}' temp_data.txt)
    awk -v max="$max_length" -v lead=">" 'max == length {gsub("\r", ""); printf "Max Length: '\''%s: %d %d %s'\''\n", lead, NR, length, $0 }' temp_data.txt
}

process_input() {
    :>temp_data.txt # Reset or create the file
    line_count=0
    while IFS= read -r line_data; do
        echo "$line_data" >>temp_data.txt
        ((line_count++))
    done
    if [ "$line_count" -gt 0 ]; then
        find_longest_line
        rm temp_data.txt
        exit 0
    else
        echo "Error: '>': No data input" >&2
        exit 1
    fi
}

if [ $# -eq 0 ]; then
    process_input
else
    files_to_process=()
    for argument in "$@"; do
        if [ "$argument" == "-h" ]; then
            show_help
            exit 0
        elif [[ "$argument" == -* ]]; then
            echo "Error: '>': Unrecognized option $argument" >&2
            exit 1
        else
            files_to_process+=("$argument")
        fi
    done
    status_code=0
    for file_path in "${files_to_process[@]}"; do
        if [ -e "$file_path" ]; then
            if [ -f "$file_path" ] && [ -r "$file_path" ]; then
                if file "$file_path" | grep -q "text"; then
                    continue
                else
                    echo "Error: '$file_path': Not a valid text file or is empty" >&2
                    status_code=1
                    files_to_process=("${files_to_process[@]/$file_path}")
                fi
            else
                echo "Error: '$file_path': File is not readable or does not exist" >&2
                status_code=1
                files_to_process=("${files_to_process[@]/$file_path}")
            fi
        else
            echo "Error: '$file_path': No such file" >&2
            status_code=1
            files_to_process=("${files_to_process[@]/$file_path}")
        fi
    done
    if [ ${#files_to_process[@]} -eq 0 ]; then
        exit 1
    fi
    max_length=$(awk 'BEGIN{max=0} max<length{max=length} END{print max}' "${files_to_process[@]}")
    for file_path in "${files_to_process[@]}"; do
        awk -v max="$max_length" -v lead="$file_path" 'max == length {gsub("\r", ""); printf "Max Length: '\''%s: %d %d %s'\''\n", lead, NR, length, $0 }' "$file_path"
    done
fi
exit $status_code

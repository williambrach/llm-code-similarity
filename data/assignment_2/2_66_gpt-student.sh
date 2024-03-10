
longest_line_length=0
line_details=()

analyze_file() {
    local line_count=0
    local content
    while IFS= read -r content; do
        ((line_count++))
        local content_length=${#content}
        if ((content_length > longest_line_length)); then
            longest_line_length=$content_length
            line_details=("$1: $line_count $content_length $content")
        elif ((content_length == longest_line_length)); then
            line_details+=("$1: $line_count $content_length $content")
        fi
    done
}

handle_arguments() {
    while [ $# -gt 0 ]; do
        case $1 in
        -h|--help)
            echo "Usage: $0 [-h] [file ...]"
            echo "      -h: Display help"
            echo "      file: File paths or none to process stdin"
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
        *)
            files_to_process+=("$1")
            ;;
        esac
        shift
    done
}

handle_arguments "$@"

if [ ${#files_to_process[@]} -eq 0 ]; then
    analyze_file "-"
else
    for file_path in "${files_to_process[@]}"; do
        if [ -f "$file_path" ] && [ -r "$file_path" ]; then
            analyze_file "$file_path" <"$file_path"
        else
            echo "Error: Cannot read $file_path" >&2
        fi
    done
fi

IFS=$'\0' sorted_line_details=($(sort -z <<<"${line_details[*]}"))
unset IFS

for detail in "${sorted_line_details[@]}"; do
    echo "$detail"
done

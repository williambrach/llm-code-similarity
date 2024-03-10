
display_usage() {
    echo "Tool to Identify the Longest Line in Provided Files"
    echo
    echo "Usage: $0 [-h] [file ...]"
    echo "      -h: display this help message"
    echo "      file ...: specify one or more files, defaults to stdin if none are given"
    echo
    exit 0
}
max_line_length=0
max_line_info=()
while getopts ":h" opt; do
    case $opt in
    h)
        display_usage
        ;;
    *)
        echo "Error: Invalid option '-$OPTARG'." >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
    input_files="/dev/stdin"
else
    input_files=("$@")
fi
for input_file in "${input_files[@]}"; do
    if [ ! -f "$input_file" ] && [ "$input_file" != "/dev/stdin" ]; then
        echo "Error: '$input_file' is not a valid file." >&2
        continue
    fi
    if [ ! -r "$input_file" ]; then
        echo "Error: '$input_file' is not readable." >&2
        continue
    fi
    if [ "$input_file" != "/dev/stdin" ]; then
        input_type=$(file -0 "$input_file" | cut -d $'\0' -f2)
    else
        input_type="text"
    fi
    if [[ "$input_type" == *"empty"* ]]; then
        echo "Error: '$input_file' is empty." >&2
        continue
    fi
    if [[ "$input_type" != *"text"* ]]; then
        echo "Error: '$input_file' is not a text file." >&2
        continue
    fi
    num_lines=0
    while IFS= read -r line; do
        ((num_lines++))
        length_of_line=${#line}
        if [ "$length_of_line" -gt "$max_line_length" ]; then
            max_line_length=$length_of_line
            max_line_info=("$input_file" "$num_lines" "$line")
        elif [ "$length_of_line" -eq "$max_line_length" ]; then
            max_line_info+=("$input_file" "$num_lines" "$line")
        fi
    done <"$input_file"
done
if [ "${#max_line_info[@]}" -eq 0 ]; then
    echo "Error: No suitable input found." >&2
    exit 1
else
    for ((i = 0; i < ${#max_line_info[@]}; i += 3)); do
        if [ "${max_line_info[i]}" == "/dev/stdin" ]; then max_line_info[i]="stdin"; fi
        echo "Longest: '${max_line_info[i]}: Line ${max_line_info[i + 1]} Length ${#max_line_info[i + 2]}: ${max_line_info[i + 2]}'"
    done
fi

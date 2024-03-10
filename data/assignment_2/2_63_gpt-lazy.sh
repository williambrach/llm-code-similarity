max_length=0
longest_content=()
line_count=0
file_paths=()
display_help() {
        echo "$0 (C)"
        echo
        echo "Usage: $0 [-h] [path ...]" # arguments 1 2 ...
        echo "[-h]: Displays help message for the user"
        echo "[path ...]: Path to the file. If no file is specified as an argument, it searches the standard input (and its name is -)"
}
for argument in "$@"; do
        if [ "$argument" == "-h" ]; then
                display_help
                exit 0
        elif echo "$argument" | grep -E -q '^-[a-gi-zA-Z]'; then
                echo "Error: '$argument: Unknown argument'" >&2
                exit 1
        elif [ ! -f "$argument" ]; then
                echo "Error: '$argument: File not found'" >&2
                exit 1
        elif [ -f "$argument" ]; then
                file_paths+=("$argument")
        elif [ "$argument" == "" ]; then
                file_paths=()
        fi
done
if [ ${#file_paths[@]} -eq 0 ]; then
        file_paths=("-")
fi
output_longest_lines() {
        if [ "${#longest_content[@]}" -gt 0 ]; then
                for ((i = 0; i < ${#longest_content[@]}; i++)); do
                        if [ "$current_file" == "-" ]; then
                                echo -e "-: ${longest_content[i]}"
                        elif [ -f "$current_file" ]; then
                                echo -e "$current_file: ${longest_content[i]}"
                        fi
                done
        fi
        longest_content=()
        max_length=0
}
for current_file in "${file_paths[@]}"; do
        max_length=0
        line_count=0
        if [ "$current_file" == "-" ]; then
                while IFS= read -r line; do
                        ((line_count++))
                        if [ "$line" == "" ]; then
                                output_longest_lines
                                exit 0
                        else
                                length=${#line}
                                if [ "$length" -gt "$max_length" ]; then
                                        longest_content=()
                                        max_length=$length
                                        longest_content+=("$line_count $max_length $line")
                                elif [ "$length" -eq "$max_length" ]; then
                                        longest_content+=("$line_count $max_length $line")
                                fi
                        fi
                done
        elif [ -f "$current_file" ]; then
                while IFS= read -r line; do
                        ((line_count++))
                        if [ "$line" == "" ]; then
                                continue
                        fi
                        length=${#line}
                        if [ "$length" -ge "$max_length" ]; then
                                if [ "$length" -gt "$max_length" ]; then
                                        max_length=$length
                                        longest_content=()
                                fi
                                longest_content+=("$line_count $max_length $line")
                        fi
                done <"$current_file"
        fi
        output_longest_lines
done
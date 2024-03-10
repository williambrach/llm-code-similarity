
display_help() {
    echo "Enhanced File Analyzer"
    echo "Syntax: <script_name> [option] [filename]"
    echo "[filename]: Analyzes and reports the longest line in the specified file"
    echo "[-h]: Shows this help message"
}

if [ "$#" -eq 0 ]; then
    temp_file="temporary.txt"
    touch "$temp_file"
    while IFS= read -r input_line; do
        [[ -z "$input_line" ]] && break
        echo "$input_line" >> "$temp_file"
    done
    max_line_length=$(awk 'BEGIN{longest=0} longest<length{ longest=length } END{print longest}' "$temp_file")
    awk -v maxlen="$max_line_length" 'length==maxlen { print "Longest Line: \047"FILENAME":",NR,length,$0"\047" }' "$temp_file"
    rm "$temp_file"
    exit 0
fi

while [ "$#" -gt 0 ]; do
    case $1 in
    -h)
        display_help
        exit 0
        ;;
    *)
        if [ -e "$1" ]; then
            if [ -f "$1" ]; then
                if [ -r "$1" ]; then
                    max_line_length=$(awk 'BEGIN{longest=0} longest<length{ longest=length } END{print longest}' "$1")
                    awk -v maxlen="$max_line_length" 'length==maxlen { print "Longest Line: \047"FILENAME":",NR,length,$0"\047" }' "$1"
                else
                    echo "Error: File '$1' is not readable" >&2
                fi
            else
                echo "Error: '$1' is a directory" >&2
            fi
        else
            echo "Error: No such file '$1'" >&2
        fi
        ;;
    esac
    shift
done

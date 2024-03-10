
function assist() {
    echo
    echo "Utility to identify the longest line within given files/directories - $0 (C)"
    echo
    echo "How to use: $0 <param1> <param2> ... <paramN>"
    echo "     <param1> File or directory to check"
    echo "     <param2> Another file or directory to check"
    echo "     ."
    echo "     ."
    echo "     ."
    echo "     <paramN> Additional file or directory to check"
    echo
    echo "This utility scans each specified file and recursively searches directories for text files to find the longest line."
    echo "Execute this utility by typing bash $0."
}
max_line_files=()        
max_line_numbers=()      
max_line_lengths=()      
max_lines=()             
current_max_length=0     
discover_max_line() {
    local file="$1"                 
    local line_number=0             
    local line_length=0            
    while IFS= read -r line; do                          
        line_number=$((line_number + 1))               
        line_length=${#line}                            
        if [ "$line_length" -ge "$current_max_length" ]; then
            max_line_files+=("$file")                   
            max_line_numbers+=("$line_number")          
            max_line_lengths+=("$line_length")          
            max_lines+=("$line")                       
            current_max_length=$line_length            
        fi
    done <"$file"
}
handle_file_or_dir() {
    local target="$1" 
    if [ -f "$target" ]; then 
        discover_max_line "$target"
    elif [ -d "$target" ]; then
        while IFS= read -r entry; do
            handle_file_or_dir "$entry"
        done < <(find "$target" -type f)
    elif [ "$target" == "-" ]; then 
        target="/dev/stdin"
        discover_max_line "$target"
    else
        echo "Error: '$target' is not a valid file or directory" >&2
        exit 1
    fi
}
for param in "${@:-"-"}"; do
    if [ "$param" == "-" ]; then
        param="/dev/stdin"
    fi
    if [ "$param" == "-h" ]; then
        assist
        exit 0
    elif [ "$param" == "/dev/stdin" ]; then
        handle_file_or_dir "-"
    else
        handle_file_or_dir "$param"
    fi
done
for ((i = 0; i < ${#max_lines[@]}; i++)); do
    if [ "${max_line_lengths[i]}" -eq "$current_max_length" ]; then
        echo "Result: ${max_line_files[i]}: ${max_line_numbers[i]} ${max_line_lengths[i]} ${max_lines[i]}"
    fi
done

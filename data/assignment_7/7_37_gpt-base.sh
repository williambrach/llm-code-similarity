
#!/bin/bash

print_help() {
    echo "Task07 (C) Revised"
    echo "Syntax: ${0} [-h] [-d depth] [directories]"
    echo "  -d depth:        Specify search depth (integer required)."
    echo "  -h:              Display help information."
    echo "  [directories]:   List of directories to search, separated by space."
}

locate_files() {
    find "$1" -maxdepth "$2" -type f | while IFS= read -r file; do
        name=$(basename "$file")
        if grep -q -- "$name" "$file"; then
            echo -n "$file "
            grep -c -- "$name" "$file"
        fi
    done
}

paths=()
search_depth=1
while [ "$#" -gt 0 ]; do
    case "$1" in
        -d)
            shift
            if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]; then
                search_depth="$1"
            else
                echo "Error: Depth '$1' is not a valid number. It must be a positive integer." >&2
                exit 1
            fi
            ;;
        -h)
            print_help
            exit 0
            ;;
        -*)
            echo "Error: Unrecognized option '$1'." >&2
            exit 1
            ;;
        *)
            paths+=("$1")
            ;;
    esac
    shift
done

if [ ${#paths[@]} -eq 0 ]; then
    locate_files "." "$search_depth"
else
    for dir in "${paths[@]}"; do
        if [ -d "$dir" ]; then
            dir_path=$(realpath "$dir")
            locate_files "$dir_path" "$search_depth"
        else
            echo "Error: Directory '$dir' is not found." >&2
            exit 1
        fi
    done
fi


#!/bin/bash

show_help() {
    cat <<HELP
Task07 (C) Revised
How to use: ${0} [-h] [-d level] [directories]
  -d level:        Set search depth (must be a number).
  -h:              Display this help message.
  [directories]:   Space-separated list of directories to search.
HELP
}

perform_search() {
    find "$1" -maxdepth "$2" -type f | while IFS= read -r file; do
        filename=$(basename "$file")
        if grep -q -- "$filename" "$file"; then
            echo -n "$file "
            grep -c -- "$filename" "$file"
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
                echo "Error: Invalid depth value '$1'. Must be a positive number." >&2
                exit 1
            fi
            ;;
        -h)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: Unknown option '$1'." >&2
            exit 1
            ;;
        *)
            paths+=("$1")
            ;;
    esac
    shift
done

if [ ${#paths[@]} -eq 0 ]; then
    perform_search "." "$search_depth"
else
    for dir in "${paths[@]}"; do
        if [ -d "$dir" ]; then
            abs_path=$(realpath "$dir")
            perform_search "$abs_path" "$search_depth"
        else
            echo "Error: Directory '$dir' does not exist." >&2
            exit 1
        fi
    done
fi


#!/bin/bash

display_usage() {
    cat <<USAGE
Task07 (C) Revised
Usage: ${0} [-h] [-d depth] [folders]
  -d depth:        Define search depth (must be numeric).
  -h:              Show this help message.
  [folders]:       Space-separated list of folders to search.
USAGE
}

search_files() {
    find "$1" -maxdepth "$2" -type f | while IFS= read -r filepath; do
        file_name=$(basename "$filepath")
        if grep -q -- "$file_name" "$filepath"; then
            echo -n "$filepath "
            grep -c -- "$file_name" "$filepath"
        fi
    done
}

directories=()
depth=1
while [ "$#" -gt 0 ]; do
    case "$1" in
        -d)
            shift
            if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]; then
                depth="$1"
            else
                echo "Error: Invalid depth value '$1'. Must be a positive integer." >&2
                exit 1
            fi
            ;;
        -h)
            display_usage
            exit 0
            ;;
        -*)
            echo "Error: Unknown option '$1'." >&2
            exit 1
            ;;
        *)
            directories+=("$1")
            ;;
    esac
    shift
done

if [ ${#directories[@]} -eq 0 ]; then
    search_files "." "$depth"
else
    for folder in "${directories[@]}"; do
        if [ -d "$folder" ]; then
            folder_path=$(realpath "$folder")
            search_files "$folder_path" "$depth"
        else
            echo "Error: Folder '$folder' does not exist." >&2
            exit 1
        fi
    done
fi

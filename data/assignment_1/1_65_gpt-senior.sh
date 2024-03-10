
#!/bin/bash

show_help() {
    cat << EOF
Script Helper (C)

Usage: ${0} [option] [directory paths]
Options:
  -h  Show this help message
  -s  Search for directories by total file size
  -l  Search for directories by total word count
Without an option, the script searches directories by total line count.

Arguments:
  directory paths  Specify one or more directories to search.
EOF
}

process_directories() {
    local mode="$1"; shift
    local dirs=("$@")
    declare -A dir_totals
    local highest_count=0
    local highest_dirs=()

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "Error: '$dir' is not a directory or does not exist." >&2
            exit 1
        fi
        find "$dir" -type d -print0 | while IFS= read -r -d '' subdir; do
            local count=0
            find "$subdir" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
                case "$mode" in
                "-s")
                    count=$((count + $(wc -c <"$file" | awk '{print $1}')))
                    ;;
                "-l")
                    count=$((count + $(wc -w <"$file" | awk '{print $1}')))
                    ;;
                *)
                    count=$((count + $(wc -l <"$file" | awk '{print $1}')))
                    ;;
                esac
            done
            if [ "$count" -gt "$highest_count" ]; then
                highest_count=$count
                highest_dirs=("$subdir")
            elif [ "$count" -eq "$highest_count" ]; then
                highest_dirs+=("$subdir")
            fi
        done
    done

    if [ ${#highest_dirs[@]} -eq 0 ]; then
        echo "No files found in given directories." >&2
        exit 1
    else
        for dir in "${highest_dirs[@]}"; do
            echo "Directory with highest count ($highest_count): $dir"
        done
    fi
}

parse_args() {
    local -a paths
    local option=""
    for arg in "$@"; do
        if [[ "$arg" == -* ]]; then
            case "$arg" in
            -h)
                show_help
                exit 0
                ;;
            -s|-l)
                option="$arg"
                ;;
            *)
                echo "Unknown option: $arg" >&2
                exit 1
                ;;
            esac
        else
            if [ -d "$arg" ]; then
                paths+=("$arg")
            else
                echo "Invalid directory: $arg" >&2
                exit 1
            fi
        fi
    done

    if [ ${#paths[@]} -eq 0 ]; then
        paths=(".")
    fi

    process_directories "$option" "${paths[@]}"
}

parse_args "$@"

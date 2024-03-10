
#!/bin/bash

display_usage() {
    cat << EOF
Directory Analyzer (C)

Usage: ${0} [option] [directory paths]
Options:
  -h  Display this help message
  -s  Analyze directories by total file size
  -l  Analyze directories by total word count
Default behavior is to analyze directories by total line count.

Arguments:
  directory paths  Specify one or more directories for analysis.
EOF
}

analyze_directories() {
    local search_mode="$1"; shift
    local target_dirs=("$@")
    declare -A dir_results
    local max_value=0
    local max_dirs=()

    for dir in "${target_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "Error: '$dir' is not a valid directory." >&2
            exit 1
        fi
        find "$dir" -type d -print0 | while IFS= read -r -d '' subdir; do
            local total=0
            find "$subdir" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
                case "$search_mode" in
                "-s")
                    total=$((total + $(wc -c <"$file" | awk '{print $1}')))
                    ;;
                "-l")
                    total=$((total + $(wc -w <"$file" | awk '{print $1}')))
                    ;;
                *)
                    total=$((total + $(wc -l <"$file" | awk '{print $1}')))
                    ;;
                esac
            done
            if [ "$total" -gt "$max_value" ]; then
                max_value=$total
                max_dirs=("$subdir")
            elif [ "$total" -eq "$max_value" ]; then
                max_dirs+=("$subdir")
            fi
        done
    done

    if [ ${#max_dirs[@]} -eq 0 ]; then
        echo "No files found in the specified directories." >&2
        exit 1
    else
        for dir in "${max_dirs[@]}"; do
            echo "Directory with the highest count ($max_value): $dir"
        done
    fi
}

handle_arguments() {
    local -a directories
    local mode=""
    for arg in "$@"; do
        if [[ "$arg" == -* ]]; then
            case "$arg" in
            -h)
                display_usage
                exit 0
                ;;
            -s|-l)
                mode="$arg"
                ;;
            *)
                echo "Unknown option: $arg" >&2
                exit 1
                ;;
            esac
        else
            if [ -d "$arg" ]; then
                directories+=("$arg")
            else
                echo "Invalid directory specified: $arg" >&2
                exit 1
            fi
        fi
    done

    if [ ${#directories[@]} -eq 0 ]; then
        directories=(".")
    fi

    analyze_directories "$mode" "${directories[@]}"
}

handle_arguments "$@"

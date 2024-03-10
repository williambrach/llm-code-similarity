
#!/bin/bash

show_help() {
    cat << HELP
Folder Analysis Tool (C)

How to use: ${0} [option] [folder paths]
Options:
  -h  Show help information
  -s  Sort folders by total size of files
  -l  Sort folders by total number of words
By default, it sorts folders by the total number of lines.

Parameters:
  folder paths  Define one or more folders to sort.
HELP
}

sort_folders() {
    local mode="$1"; shift
    local folders=("$@")
    declare -A results
    local highest=0
    local highest_folders=()

    for folder in "${folders[@]}"; do
        if [ ! -d "$folder" ]; then
            echo "Error: '$folder' is not a valid folder." >&2
            exit 1
        fi
        find "$folder" -type d -print0 | while IFS= read -r -d '' subfolder; do
            local sum=0
            find "$subfolder" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' item; do
                case "$mode" in
                "-s")
                    sum=$((sum + $(wc -c <"$item" | awk '{print $1}')))
                    ;;
                "-l")
                    sum=$((sum + $(wc -w <"$item" | awk '{print $1}')))
                    ;;
                *)
                    sum=$((sum + $(wc -l <"$item" | awk '{print $1}')))
                    ;;
                esac
            done
            if [ "$sum" -gt "$highest" ]; then
                highest=$sum
                highest_folders=("$subfolder")
            elif [ "$sum" -eq "$highest" ]; then
                highest_folders+=("$subfolder")
            fi
        done
    done

    if [ ${#highest_folders[@]} -eq 0 ]; then
        echo "No files found in the specified folders." >&2
        exit 1
    else
        for folder in "${highest_folders[@]}"; do
            echo "Folder with the highest count ($highest): $folder"
        done
    fi
}

process_args() {
    local -a folders
    local search_mode=""
    for arg in "$@"; do
        if [[ "$arg" == -* ]]; then
            case "$arg" in
            -h)
                show_help
                exit 0
                ;;
            -s|-l)
                search_mode="$arg"
                ;;
            *)
                echo "Unknown option: $arg" >&2
                exit 1
                ;;
            esac
        else
            if [ -d "$arg" ]; then
                folders+=("$arg")
            else
                echo "Invalid folder specified: $arg" >&2
                exit 1
            fi
        fi
    done

    if [ ${#folders[@]} -eq 0 ]; then
        folders=(".")
    fi

    sort_folders "$search_mode" "${folders[@]}"
}

process_args "$@"

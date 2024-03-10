$()$(
    assist() {
        echo "$(basename "$0") (C)"
        echo ""
        echo "Usage: $(basename "$0") [-h] [-l <level>] [directory ...]"
        echo "-h - This help message"
        echo "-l <level> - Level of depth for search (optional)"
        echo "directory - Directories to search (optional)"
    }
    isValidNumber() {
        local num=$1
        if [ "$debug_mode" = true ]; then
            echo "Debug: isValidNumber: '$num'"
        fi
        if [[ "$num" =~ ^[0-9]+$ ]]; then
            return 0 # true (0 is good return value)
        else
            return 1 # false
        fi
    }
    find_text_in_files() {
        local target_dir="$1"
        local level="$2"
        if [ "$debug_mode" = true ]; then
            echo "Debug: target_dir: '$target_dir'"
            echo "Debug: level: '$level'"
        fi
        if [ -d "$target_dir" ]; then
            while IFS= read -r -d '' file; do
                occurrences=$(grep -c "$(basename "$file")" "$file")
                if [ "$occurrences" -gt 0 ]; then
                    echo "Found: '$file $occurrences'"
                fi
            done < <(find "$target_dir" -maxdepth "$level" -type f -name '*.txt' -print0 2> >(sed 's/find/Error/g' >&2))
        else
            echo "Error: '$target_dir': is not a valid directory." >&2
            exit 1
        fi
    }
    debug_mode=false # Debug mode off by default
    level=999999     # Default level
    target_dir="."   # Default target directory
    if [ "$debug_mode" = true ]; then
        echo "Current directory: '$(pwd)'"
    fi
    while getopts ":hl:" opt; do
        if [ "$debug_mode" = true ]; then
            echo "Debug: $opt $OPTARG"
            echo "Debug: $opt $OPTARG"
        fi
        case $opt in
        h)
            assist
            exit 0
            ;;
        l)
            if isValidNumber "$OPTARG"; then
                level="$OPTARG"
            else
                echo "Error: '-$opt': level must be a natural number" >&2
                exit 1
            fi
            if [ "$level" -lt 1 ]; then
                echo "Error: '-$opt': level must be greater than 0" >&2
                exit 1
            fi
            ;;
        :)
            echo "Error: '-$OPTARG': argument must not be empty" >&2
            exit 1
            ;;
        \?)
            echo "Error: '-$OPTARG': is not valid argument" >&2
            exit 1
            ;;
        esac
    done
    shift $((OPTIND - 1))
    if [ "$debug_mode" = true ]; then
        for arg; do
            echo "Debug: Remaining argument: '$arg'"
        done
    fi
    if [ $# -eq 0 ]; then
        find_text_in_files "$target_dir" "$level"
        exit 0
    fi
    while [ $# -gt 0 ]; do
        find_text_in_files "$1" "$level"
        shift
    done
)$()

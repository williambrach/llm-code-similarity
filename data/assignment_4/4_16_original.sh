
# Resetting environment variables
unset searchDepth
unset searchPaths
unset directoryFound

# Parsing command-line inputs
while [ $# -gt 0 ]; do
    case "$1" in
        -d) # Define maximum depth for search
            if [ $# -lt 2 ]; then
                echo "Error: -d option requires a numerical value"
                exit 1
            fi
            if ! [[ $2 =~ ^[0-9]+$ ]] || [ $2 -lt 1 ]; then
                echo "Error: Depth value must be a positive integer"
                exit 1
            fi
            searchDepth=$2
            shift
            ;;
        -h) # Display help information
            echo "Usage: script.sh -d <depth> -h <path1> <path2> ..."
            echo "-d <depth>: Set the search depth (must be a positive integer)"
            echo "-h: Show help information"
            echo "<path1> <path2> ...: Paths to search (if none are provided, defaults to the current directory)"
            exit 0
            ;;
        -*) # Handle invalid options
            echo "Error: Unknown option $1"
            exit 1
            ;;
        *) # Check if directory exists
            if [ -d "$1" ]; then
                directoryFound=0
                for path in "${searchPaths[@]}"; do
                    if [ "$(realpath "$path")" = "$(realpath "$1")" ]; then
                        directoryFound=1
                        break
                    fi
                done
                if [ $directoryFound -eq 0 ]; then
                    searchPaths+=("$1")
                fi
            else
                echo "Error: $1 is not a valid directory."
                exit 1
            fi
            ;;
    esac
    shift
done

# If no paths are specified, use the current directory
if [ -z "${searchPaths[*]}" ]; then
    searchPaths=(".")
fi

# Examine each specified path
for path in "${searchPaths[@]}"; do
    echo "Examining path: $path"
    unset linkList
    unset destinationList
    IFS=$'\n'
    # Collect symlinks and their destinations
    if [ -z "$searchDepth" ]; then
        linkList=($(find "$path" -type l))
        destinationList=($(find "$path" -type l -exec readlink {} \;))
    else
        linkList=($(find "$path" -maxdepth "$searchDepth" -type l))
        destinationList=($(find "$path" -maxdepth "$searchDepth" -type l -exec readlink {} \;))
    fi
    unset IFS
    # Determine the longest destination path
    unset maxPathLength
    maxPathLength=$(printf "%s\n" "${destinationList[@]}" | awk -F/ '{print NF-1}' | sort -nr | head -n1)
    # Display symlinks that point to the longest destination path
    for i in "${!linkList[@]}"; do
        if [ "$(echo "${destinationList[$i]}" | awk -F/ '{print NF-1}')" -eq "$maxPathLength" ]; then
            echo "${linkList[$i]} -> ${destinationList[$i]}"
        fi
    done
done

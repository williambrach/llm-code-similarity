
# Clearing variables
unset maxDepthLevel
unset directoriesToSearch
unset foundDirectoryFlag

# Handling command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -d) # Set maximum search depth
            if [ $# -lt 2 ]; then
                echo "Error: Missing value for -d option"
                exit 1
            fi
            if ! [[ $2 =~ ^[0-9]+$ ]] || [ $2 -lt 1 ]; then
                echo "Error: Depth must be a positive number"
                exit 1
            fi
            maxDepthLevel=$2
            shift
            ;;
        -h) # Show help message
            echo "Usage: script.sh -d <depth> -h <dir1> <dir2> ..."
            echo "-d <depth>: Specify search depth (positive number)"
            echo "-h: Display this help message"
            echo "<dir1> <dir2> ...: Directories to be searched (defaults to current directory if none provided)"
            exit 0
            ;;
        -*) # Handle unknown options
            echo "Error: Unrecognized option $1"
            exit 1
            ;;
        *) # Validate directory existence
            if [ -d "$1" ]; then
                foundDirectoryFlag=0
                for dir in "${directoriesToSearch[@]}"; do
                    if [ "$(realpath "$dir")" = "$(realpath "$1")" ]; then
                        foundDirectoryFlag=1
                        break
                    fi
                done
                if [ $foundDirectoryFlag -eq 0 ]; then
                    directoriesToSearch+=("$1")
                fi
            else
                echo "Error: Directory $1 does not exist."
                exit 1
            fi
            ;;
    esac
    shift
done

# Default to current directory if no directories specified
if [ -z "${directoriesToSearch[*]}" ]; then
    directoriesToSearch=(".")
fi

# Process each specified directory
for dir in "${directoriesToSearch[@]}"; do
    echo "Processing directory: $dir"
    unset symlinkList
    unset targetList
    IFS=$'\n'
    # Retrieve symlinks and their targets
    if [ -z "$maxDepthLevel" ]; then
        symlinkList=($(find "$dir" -type l))
        targetList=($(find "$dir" -type l -exec readlink {} \;))
    else
        symlinkList=($(find "$dir" -maxdepth "$maxDepthLevel" -type l))
        targetList=($(find "$dir" -maxdepth "$maxDepthLevel" -type l -exec readlink {} \;))
    fi
    unset IFS
    # Identify the longest target path
    unset longestPath
    longestPath=$(printf "%s\n" "${targetList[@]}" | awk -F/ '{print NF-1}' | sort -nr | head -n1)
    # Output symlinks pointing to the longest target path
    for i in "${!symlinkList[@]}"; do
        if [ "$(echo "${targetList[$i]}" | awk -F/ '{print NF-1}')" -eq "$longestPath" ]; then
            echo "${symlinkList[$i]} -> ${targetList[$i]}"
        fi
    done
done


# Resetting variables
unset depthLimit
unset searchDirs
unset isDirFound

# Parsing command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -d) # Define search depth
            if [ $# -lt 2 ]; then
                echo "Error: Missing argument for -d option"
                exit 1
            fi
            if ! [[ $2 =~ ^[0-9]+$ ]] || [ $2 -lt 1 ]; then
                echo "Error: Depth must be a positive integer"
                exit 1
            fi
            depthLimit=$2
            shift
            ;;
        -h) # Display help
            echo "Usage: script.sh -d <number> -h <dir1> <dir2> ..."
            echo "-d <number>: Set search depth (must be positive integer)"
            echo "-h: Show help information"
            echo "<dir1> <dir2> ...: Directories to search (defaults to current directory if none)"
            exit 0
            ;;
        -*) # Unknown option
            echo "Error: Unknown option $1"
            exit 1
            ;;
        *) # Check for directory existence
            if [ -d "$1" ]; then
                isDirFound=0
                for directory in "${searchDirs[@]}"; do
                    if [ "$(realpath "$directory")" = "$(realpath "$1")" ]; then
                        isDirFound=1
                        break
                    fi
                done
                if [ $isDirFound -eq 0 ]; then
                    searchDirs+=("$1")
                fi
            else
                echo "Error: Directory $1 does not exist."
                exit 1
            fi
            ;;
    esac
    shift
done

# Default to current directory if none specified
if [ -z "${searchDirs[*]}" ]; then
    searchDirs=(".")
fi

# Process each directory
for directory in "${searchDirs[@]}"; do
    echo "Processing directory: $directory"
    unset symlinkPaths
    unset targetPaths
    IFS=$'\n'
    # Find symlinks and their targets
    if [ -z "$depthLimit" ]; then
        symlinkPaths=($(find "$directory" -type l))
        targetPaths=($(find "$directory" -type l -exec readlink {} \;))
    else
        symlinkPaths=($(find "$directory" -maxdepth "$depthLimit" -type l))
        targetPaths=($(find "$directory" -maxdepth "$depthLimit" -type l -exec readlink {} \;))
    fi
    unset IFS
    # Determine the longest path
    unset maxDepth
    maxDepth=$(printf "%s\n" "${targetPaths[@]}" | awk -F/ '{print NF-1}' | sort -nr | head -n1)
    # Display symlinks with the longest target path
    for i in "${!symlinkPaths[@]}"; do
        if [ "$(echo "${targetPaths[$i]}" | awk -F/ '{print NF-1}')" -eq "$maxDepth" ]; then
            echo "${symlinkPaths[$i]} -> ${targetPaths[$i]}"
        fi
    done
done

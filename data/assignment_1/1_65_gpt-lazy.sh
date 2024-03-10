function assist() {
    echo "Program Name (C)"
    echo
    echo "Usage: $0 <option1> <option2>"
    echo "<option1>: [-h] [-s] [-l]"
    echo "-h: Display script usage options"
    echo "-s: Find directories with the largest total number of characters in files"
    echo "-l: Find directories with the largest total number of words in files"
    echo "Without switch: Finds directories with the largest total number of lines in files"
    echo
    echo "<option2>: [paths]"
    echo "[paths ...]: Paths to directories for processing"
}
function calculate() {
    local switch="$1"
    shift
    local paths=("$@")
    max_dirs=()
    max_total=0
    file_exists=0
    for path in "${paths[@]}"; do
        mapfile -t subdirs < <(
            find "$path" -type d 2>/dev/null || {
                echo "Error: Directory '$path' not found" >&2
                exit 1
            }
        )
        for subdir in "${subdirs[@]}"; do
            total=0
            while IFS= read -r -d $'\0' file; do
                file_exists=1
                case "$switch" in
                "")
                    total=$((total + $(wc -l <"$file")))
                    ;;
                "-l")
                    total=$((total + $(wc -w <"$file")))
                    ;;
                "-s")
                    total=$((total + $(wc -c <"$file")))
                    ;;
                esac
            done < <(find "$subdir" -maxdepth 1 -type f -print0)
            if [ $total -gt $max_total ]; then
                max_total=$total
                max_dirs=("$subdir")
            elif [ $total -eq $max_total ]; then
                max_dirs+=("$subdir")
            fi
        done
    done
    if [ $file_exists -eq 1 ]; then
        for max_dir in "${max_dirs[@]}"; do
            echo "Result: '$max_dir $max_total'"
        done
        exit 0
    else
        echo "Error: No files found in the specified directories and their subdirectories. Exiting." >&2
        exit 1
    fi
}
switch=""
paths=()
saved_args=()
for arg in "${@:1}"; do
    absolute_path=$(realpath "$arg" 2>/dev/null || echo "$arg")
    relative_path=$(realpath --relative-to=. "$absolute_path" 2>/dev/null || echo "$arg")
    exists=false
    for item in "${saved_args[@]}"; do
        if [ "$item" == "$relative_path" ]; then
            exists=true
            break
        fi
    done
    if [ "$exists" == true ]; then
        continue
    fi
    saved_args+=("$relative_path")
    if [ "${relative_path:0:1}" == "-" ]; then
        case "$relative_path" in
        "-h")
            assist
            exit 0
            ;;
        "-s" | "-l" | "")
            switch="$relative_path"
            ;;
        *)
            echo "Error: '$relative_path' Unknown switch. Exiting." >&2
            exit 1
            ;;
        esac
    elif [ -d "$absolute_path" ]; then
        paths+=("$relative_path")
    else
        echo "Error: '$relative_path' is not a valid directory. Exiting." >&2
        exit 1
    fi
done
if [ "${#paths[@]}" -eq 0 ]; then
    paths=(".")
fi
case "$switch" in
"")
    calculate "$switch" "${paths[@]}"
    ;;
"-s")
    calculate "$switch" "${paths[@]}"
    ;;
"-l")
    calculate "$switch" "${paths[@]}"
    ;;
esac


display_help() {
  echo "Application Title (C)"
  echo "Usage: $0 [-h] [-d <depth>] [path ...]"
  echo "  -h: Display this help message"
  echo "  -d <depth>: Set search depth"
  echo "  path: Directories to search"
}

search_depth=""
while getopts ":hd:" option; do
  case $option in
  h) # Display help
    display_help
    exit 0
    ;;
  d) # Set search depth
    search_depth=$OPTARG
    ;;
  \?)
    echo "Error: Unknown option: -$OPTARG" >&2
    exit 1
    ;;
  :)
    echo "Error: Option -$OPTARG requires a value" >&2
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))
directories=("$@")
if [ ${#directories[@]} -eq 0 ]; then
  directories=(".")
fi

deepest_depth=-1
deepest_symlinks=()
for dir in "${directories[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "Error: '$dir' is not a valid directory" >&2
    continue
  fi
  while IFS= read -r -d '' link; do
    link_target=$(readlink -f -- "$link")
    link_depth=$(echo "$link_target" | awk -F"/" '{print NF-1}')
    if [ "$link_depth" -gt $deepest_depth ]; then
      deepest_depth=$link_depth
      deepest_symlinks=("$link -> $link_target")
    elif [ "$link_depth" -eq $deepest_depth ]; then
      deepest_symlinks+=("$link -> $link_target")
    fi
  done < <(find "$dir" -maxdepth "${search_depth:-999}" -type l -print0)
done

for symlink in "${deepest_symlinks[@]}"; do
  echo "Result: '$symlink'"
done

[[ ${#deepest_symlinks[@]} -eq 0 ]] && echo "No links found."

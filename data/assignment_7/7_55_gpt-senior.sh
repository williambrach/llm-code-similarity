
display_help() {
  echo "Usage Guide for task07 (B)"
  echo -e "\nSyntax: $0 [-h] [-d <depth>] [directory ...]"
  echo "   option1: aaaaa"
  echo "   option2: bbbbb"
  exit 0
}
log_error() {
  echo "Encountered Error: '$1': $2" >&2
  exit 1
}
search_for_text_files() {
  local depth_level=$1
  local directory_path=$2
  while IFS= read -r filename; do
    if [ -f "$filename" ]; then
      occurrences=$(grep -w -c "$(basename "$filename")" "$filename")
      echo "Found: '$filename $occurrences'"
    fi
  done < <(find "$directory_path" -type f -name '*.txt' -print)
}
while getopts ":hd:" option; do
  case $option in
  h) display_help ;;
  d) depth="$OPTARG" ;;
  \?) log_error "Invalid command" "Please use -h for help." ;;
  esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
  directories="."
else
  directories="$@"
fi
if [ -z "$depth" ]; then
  depth=$(find "$directories" -type d | awk -F'/' '{print NF}' | sort -nu | tail -n 1)
fi
for dir in $directories; do
  if [ ! -e "$dir" ]; then
    log_error "$dir" "Directory does not exist."
  fi
  if [ ! -d "$dir" ]; then
    log_error "$dir" "It is not a directory."
  fi
  search_for_text_files "$depth" "$dir"
done

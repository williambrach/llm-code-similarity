
display_help() {
  echo "How to use task07 (B)"
  echo -e "\nExample: $0 [-h] [-d <depth>] [directory ...]"
  echo "   option1: aaaaa"
  echo "   option2: bbbbb"
  exit 0
}
error_message() {
  echo "Error Detected: '$1': $2" >&2
  exit 1
}
search_for_txt_files() {
  local depth=$1
  local dir=$2
  while IFS= read -r txt_file; do
    if [ -f "$txt_file" ]; then
      occurrences=$(grep -w -c "$(basename "$txt_file")" "$txt_file")
      echo "Match: '$txt_file $occurrences'"
    fi
  done < <(find "$dir" -maxdepth "$depth" -type f -name '*.txt' -print)
}
while getopts ":hd:" option; do
  case $option in
  h) display_help ;;
  d) depth_level="$OPTARG" ;;
  \?) error_message "Invalid option" "Use -h for help." ;;
  esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
  directories="."
else
  directories="$@"
fi
if [ -z "$depth_level" ]; then
  depth_level=$(find "$directories" -type d | awk -F'/' '{print NF}' | sort -nu | tail -n 1)
fi
for dir in $directories; do
  if [ ! -e "$dir" ]; then
    error_message "$dir" "Directory not found."
  fi
  if [ ! -d "$dir" ]; then
    error_message "$dir" "Not a directory."
  fi
  search_for_txt_files "$depth_level" "$dir"
done

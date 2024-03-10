assist_function() {
	echo "$0 (C)"
	echo ""
	echo "Usage: $0 [-h][-l <level>] [directory ...]"
	echo "[-h]: Displays this help message"
	echo "[-l <level>]: Level of depth for file search. Defaults to 1 if not specified"
	echo "[directory ...]: Directories to search"
}
search_level='1'
search_dirs=()
while getopts ":hsl:" opt; do
	case $opt in
	h)
		assist_function
		exit 0
		;;
	l)
		search_level="$OPTARG"
		if ! [[ "$search_level" =~ ^[1-9][0-9]*$ ]]; then
			echo "Error: Invalid argument for level. Must be a positive integer." >&2
			exit 1
		fi
		;;
	:)
		echo "Error: Option '-$OPTARG' requires an argument." >&2
		exit 1
		;;
	?)
		echo "Error: Invalid option. Use -h for help" >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))
while [ $# -gt 0 ]; do
	search_dirs+=("$1")
	shift
done
if [ "${#search_dirs[@]}" -eq 0 ]; then
	search_dirs=(".")
fi
found_files=()
for dir in "${search_dirs[@]}"; do
	if ! [[ -d "$dir" ]]; then
		echo "Error: directory $dir does not exist" >&2
		exit 1
	fi
	old_IFS=$IFS
	IFS='
	'
	while IFS= read -r -d '' file; do
		if file "$file" | grep -q text && [ -r "$file" ]; then
			found_files+=("$file")
			filename=$(basename "$file")
			line_count=$(grep -ce "$filename" "$file")
			if [[ $line_count -gt 0 ]]; then
				echo "$(realpath "$file") $line_count"
			fi
		fi
	done < <(find "$dir" -maxdepth "$search_level" -type f -print0 2>&1)
	IFS=$old_IFS
done

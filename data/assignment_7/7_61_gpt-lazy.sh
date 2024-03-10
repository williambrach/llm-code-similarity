assist_function() {
	echo "$0 (C)"
	echo ""
	echo "Usage: $0 [-h][-d <depth>] [path ...]"
	echo "[-h]: Displays this help message"
	echo "[-d <depth>]: Depth for file search. Defaults to 1 if not specified"
	echo "[path ...]: Directories to search"
}
search_depth='1'
search_paths=()
while getopts ":hsd:" option; do
	case $option in
	h)
		assist_function
		exit 0
		;;
	d)
		search_depth="$OPTARG"
		if ! [[ "$search_depth" =~ ^[1-9][0-9]*$ ]]; then
			echo "Error: Invalid argument for depth. Must be a positive number." >&2
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
	search_paths+=("$1")
	shift
done
if [ "${#search_paths[@]}" -eq 0 ]; then
	search_paths=(".")
fi
found_files=()
for directory in "${search_paths[@]}"; do
	if ! [[ -d "$directory" ]]; then
		echo "Error: directory $directory does not exist" >&2
		exit 1
	fi
	old_IFS=$IFS
	IFS='
	'
	while IFS= read -r -d '' item; do
		if file "$item" | grep -q text && [ -r "$item" ]; then
			found_files+=("$item")
			item_name=$(basename "$item")
			item_count=$(grep -ce "$item_name" "$item")
			if [[ $item_count -gt 0 ]]; then
				echo "$(realpath "$item") $item_count"
			fi
		fi
	done < <(find "$directory" -maxdepth "$search_depth" -type f -print0 2>&1)
	IFS=$old_IFS
done

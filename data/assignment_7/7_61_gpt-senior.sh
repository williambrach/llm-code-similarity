
help_message() {
	echo "$0 (C)"
	echo ""
	echo "How to use: $0 [-h] [-d <level>] [directory ...]"
	echo "[-h]: Show help information"
	echo "[-d <level>]: Set search level. Default is 1 if not set"
	echo "[directory ...]: Directories to look in"
}
depth='1'
directories=()
while getopts ":hd:" opt; do
	case $opt in
	h)
		help_message
		exit 0
		;;
	d)
		depth="$OPTARG"
		if ! [[ "$depth" =~ ^[1-9][0-9]*$ ]]; then
			echo "Error: Depth must be a positive integer." >&2
			exit 1
		fi
		;;
	:)
		echo "Error: Missing argument for option '-$OPTARG'." >&2
		exit 1
		;;
	?)
		echo "Error: Unknown option. Use -h for help." >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))
while [ $# -gt 0 ]; do
	directories+=("$1")
	shift
done
if [ "${#directories[@]}" -eq 0 ]; then
	directories=(".")
fi
matched_files=()
for dir in "${directories[@]}"; do
	if ! [[ -d "$dir" ]]; then
		echo "Error: $dir is not a valid directory" >&2
		exit 1
	fi
	save_IFS=$IFS
	IFS=$'\n'
	while IFS= read -r -d '' file; do
		if file "$file" | grep -q text && [ -r "$file" ]; then
			matched_files+=("$file")
			file_name=$(basename "$file")
			count=$(grep -ce "$file_name" "$file")
			if [[ $count -gt 0 ]]; then
				echo "$(realpath "$file") $count"
			fi
		fi
	done < <(find "$dir" -maxdepth "$depth" -type f -print0 2>&1)
	IFS=$save_IFS
done

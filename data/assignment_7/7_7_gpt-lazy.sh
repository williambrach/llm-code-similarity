function assist() {
	cat <<EOF
Task07 (C)
Usage: $0 -h -d <level> [folders]
  -d <level>:      Define the search depth (numeric).
  -h:              Show this help info.
  [folders]:       List of folders to search, separated by space.
EOF
}
function search() {
	find "$1" -maxdepth "$2" -type f -print | while read -r item; do
		item_name=$(basename "$item")
		if grep -q -- "$item_name" "$item"; then
			printf "%s " "$item"
			grep -c -- "$item_name" "$item"
		fi
	done
}
directories=()
depth=1
while (("$#")); do
	case "$1" in
	-d)
		shift
		if [ -n "$1" ]; then
			if [[ "$1" =~ ^[0-9]+$ ]]; then
				if [ "$1" -gt 0 ]; then
					depth="$1"
				else
					echo "Error: '$1': Depth must be greater than 0" >&2
					exit 1
				fi
			else
				echo "Error: '$1': incorrect value after -d, enter a number" >&2
				exit 1
			fi
		else
			echo "Error: missing value after -d" >&2
			exit 1
		fi
		;;
	-h)
		assist
		exit 0
		;;
	-*)
		echo "Error: '$1': unknown option" >&2
		exit 1
		;;
	*)
		directories+=("$1")
		;;
	esac
	shift
done
if [ ${#directories[@]} -eq 0 ]; then
	search "$PWD" "$depth"
else
	for folder in "${directories[@]}"; do
		if [[ -e "$folder" ]]; then
			folder_path=$(realpath "$folder")
			search "$folder_path" "$depth"
		else
			echo "Error: '$folder': specified folder does not exist" >&2
			exit 1
		fi
	done
fi

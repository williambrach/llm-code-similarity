
usage() {
	echo "Task 7 - Name Occurrence Finder (C)"
	echo ""
	echo "Syntax: $0 <-h> <-d (depth)> <path>"
	echo "<-h>: displays this help message"
	echo "<-d>: sets the search depth, followed by a natural number N"
	echo "<path>: the directory path to start the search"
}
files=()
add_files() {
	local directory="$1"
	if grep -qE "^find: .*" <<<"$directory"; then
		echo "Find command error" 1>&2
		exit 1
	else
		if file "$directory" | grep -qi "text"; then
			if [[ -r "$directory" ]]; then
				files+=("$directory")
			fi
		fi
	fi
}
depth=""
path=""
while (("$#")); do
	case "$1" in
	-h)
		usage
		exit 0
		;;
	-d)
		shift
		is_number="^[0-9]+$"
		if [[ "$1" =~ $is_number ]]; then
			depth=$1
		else
			bad_value=$1
			printf "Error: \'Invalid depth value -> %s\'\n" "$bad_value" 1>&2
			exit 1
		fi
		;;
	-*)
		printf "Error: \'Invalid option -> %s\'\n" "$1" 1>&2
		exit 1
		;;
	*)
		if test -d "$1"; then
			path="$1"
		else
			bad_path="$1"
			printf "Error: \'Invalid path / Directory does not exist -> %s\'\n" "$bad_path" 1>&2
			exit 1
		fi
		;;
	esac
	shift
done
if [[ -z "$path" ]]; then
	path="."
fi
if [ -z "$depth" ]; then
	directories=$(find "$path" -type f 2>&1)
	while read -r directory; do
		add_files "$directory"
	done <<<"$directories"
else
	directories=$(find "$path" -maxdepth "$depth" -type f 2>&1)
	while read -r directory; do
		add_files "$directory"
	done <<<"$directories"
fi
for file in "${files[@]}"; do
	name=$(basename "$file")
	count=$(grep -wc "$name" "$file")
	if [[ $count -gt 0 ]]; then
		printf "Output: \'%s %s\'\n" "$file" "$count"
	fi
done
exit 0

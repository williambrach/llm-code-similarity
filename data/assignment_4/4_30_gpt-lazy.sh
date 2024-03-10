assist() {
	echo "task04.sh (C)"
	echo
	echo "Usage: task04.sh [-h] [-d <depth>] [path ...]"
	echo "-h: Display this help message"
	echo "-d: <depth>: Search only to a specified depth"
	echo "path: paths to the directories to be searched"
	echo
}
update_longest_link() {
	if [ "$1" -gt "${longest_link_count[0]}" ]; then
		longest_link_count=("$1")
		longest_link=("$2")
		deepest_path=("$(readlink -f "$2")")
	elif [ "$1" -eq "${longest_link_count[0]}" ]; then
		longest_link_count+=("$1")
		longest_link+=("$2")
		deepest_path+=("$(readlink -f "$2")")
	fi
}
count_path_parts() {
	input="$1"
	size=${#input}
	if [ "$size" -eq 1 ]; then
		echo "1"
	else
		echo "$1" | tr '/' '\n' | wc -l
	fi
}
display_results() {
	count=${#longest_link_count[@]}
	if [ "${longest_link_count[0]}" -gt 0 ]; then
		for ((i = 0; i < "$count"; i++)); do
			echo "${longest_link[$i]}" '->' "${deepest_path[$i]}"
		done
	fi
}
search_depth=-1
if [ "$1" == "-h" ]; then
	(assist)
	shift
fi
if [ "$1" == "-d" ]; then
	if [ "$2" -gt 0 ]; then
		search_depth="$2"
		shift 2
	else
		echo "Error: '$2': Depth must be greater than 0" >&2
		exit 1
	fi
fi
folders=("$@")
for folder in "${folders[@]}"; do
	if ! [[ -e "$folder" ]]; then
		echo "Error: '$folder': Directory does not exist" >&2
	else
		updated_folders+=("$folder")
	fi
done
if [ ${#folders[@]} -eq 0 ]; then
	folders=(".")
else
	folders=("${updated_folders[@]}")
fi
longest_link_count=(0)
if [ ${#folders[@]} -eq 0 ]; then
	exit 1
fi
for folder in "${folders[@]}"; do
	if [ "$search_depth" -ne -1 ]; then
		while IFS= read -r -d '' link; do
			link_path=$(readlink -f "$link")
			path_parts=$(count_path_parts "$link_path")
			if [ "$path_parts" -ge "${longest_link_count[0]}" ]; then
				update_longest_link "$path_parts" "$link"
			fi
		done < <(find "$folder" -maxdepth "$search_depth" -type l -print0)
	else
		while IFS= read -r -d '' link; do
			link_path=$(readlink -f "$link")
			path_parts=$(count_path_parts "$link_path")
			if [ "$path_parts" -ge "${longest_link_count[0]}" ]; then
				update_longest_link "$path_parts" "$link"
			fi
		done < <(find "$folder" -type l -print0)
	fi
done
display_results

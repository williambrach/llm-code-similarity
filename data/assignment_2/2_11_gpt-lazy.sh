show_help() {
	echo "Max Line Length Finder"
	echo
	echo "Usage: $0 [-h] [path ...]"
	echo "      -h: displays this message"
	echo "      path ...: 1 or more file paths, if not specified reads from stdin"
	echo
	exit 0
}
longest_line=0
longest_content=()
while getopts ":h" option; do
	case $option in
	h)
		show_help
		;;
	\?)
		echo "Error: Invalid option '-$OPTARG'." >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
	targets="/dev/stdin"
else
	targets=("$@")
fi
for target in "${targets[@]}"; do
	if [ ! -f "$target" ] && [ "$target" != "/dev/stdin" ]; then
		echo "Error: '$target': file does not exist." >&2
		continue
	fi
	if [ ! -r "$target" ]; then
		echo "Error: '$target': file is not readable." >&2
		continue
	fi
	if [ "$target" != "/dev/stdin" ]; then
		target_info=$(file -0 "$target" | cut -d $'\0' -f2)
	else
		target_info="text"
	fi
	if [[ "$target_info" == *"empty"* ]]; then
		echo "Error: '$target': file is empty." >&2
		continue
	fi
	if [[ "$target_info" != *"text"* ]]; then
		echo "Error: '$target': file is not a text file." >&2
		continue
	fi
	line_count=0
	while IFS= read -r line; do
		((line_count++))
		line_length=${#line}
		if [ "$line_length" -gt "$longest_line" ]; then
			longest_line=$line_length
			longest_content=("$target" "$line_count" "$line")
		elif [ "$line_length" -eq "$longest_line" ]; then
			longest_content+=("$target" "$line_count" "$line")
		fi
	done <"$target"
done
if [ "${#longest_content[@]}" -eq 0 ]; then
	echo "Error: '$0': No input provided." >&2
	exit 1
else
	for ((i = 0; i < ${#longest_content[@]}; i += 3)); do
		if [ "${longest_content[i]}" == "/dev/stdin" ]; then longest_content[i]="-"; fi
		echo "Result: '${longest_content[i]}: ${longest_content[i + 1]} ${#longest_content[i + 2]} ${longest_content[i + 2]}'"
	done
fi

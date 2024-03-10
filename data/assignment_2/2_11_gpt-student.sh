
show_help() {
	echo "Utility to Find Longest Line in Files"
	echo
	echo "Syntax: $0 [-h] [file ...]"
	echo "      -h: shows this help text"
	echo "      file ...: one or more files to check, reads from stdin if none specified"
	echo
	exit 0
}
longest_line_length=0
longest_line_details=()
while getopts ":h" option; do
	case $option in
	h)
		show_help
		;;
	*)
		echo "Error: Unknown option '-$OPTARG'." >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
	file_paths="/dev/stdin"
else
	file_paths=("$@")
fi
for file_path in "${file_paths[@]}"; do
	if [ ! -f "$file_path" ] && [ "$file_path" != "/dev/stdin" ]; then
		echo "Error: '$file_path' does not exist as a file." >&2
		continue
	fi
	if [ ! -r "$file_path" ]; then
		echo "Error: '$file_path' cannot be read." >&2
		continue
	fi
	if [ "$file_path" != "/dev/stdin" ]; then
		file_type=$(file -0 "$file_path" | cut -d $'\0' -f2)
	else
		file_type="text"
	fi
	if [[ "$file_type" == *"empty"* ]]; then
		echo "Error: '$file_path' is empty." >&2
		continue
	fi
	if [[ "$file_type" != *"text"* ]]; then
		echo "Error: '$file_path' is not a text file." >&2
		continue
	fi
	line_count=0
	while IFS= read -r line; do
		((line_count++))
		line_length=${#line}
		if [ "$line_length" -gt "$longest_line_length" ]; then
			longest_line_length=$line_length
			longest_line_details=("$file_path" "$line_count" "$line")
		elif [ "$line_length" -eq "$longest_line_length" ]; then
			longest_line_details+=("$file_path" "$line_count" "$line")
		fi
	done <"$file_path"
done
if [ "${#longest_line_details[@]}" -eq 0 ]; then
	echo "Error: No valid input detected." >&2
	exit 1
else
	for ((i = 0; i < ${#longest_line_details[@]}; i += 3)); do
		if [ "${longest_line_details[i]}" == "/dev/stdin" ]; then longest_line_details[i]="stdin input"; fi
		echo "Longest: '${longest_line_details[i]}: Line ${longest_line_details[i + 1]} Length ${#longest_line_details[i + 2]}: ${longest_line_details[i + 2]}'"
	done
fi

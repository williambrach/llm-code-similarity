function show_instructions() {
	echo "$0 (C)"
	echo
	echo "How to use: $0 <param1> <param2> ..."
	echo "  <param1>: Path to file or directory to find the longest line"
	echo "  <param2>: Path to another file or directory for longest line search"
	echo "         (multiple paths can be specified)"
	echo
	echo "  This utility must be run with BASH, not sh"
	echo "Without any parameters, the utility will accept input from standard input."
}
if [ "$1" == "-h" ]; then
	show_instructions
	exit 0
fi
longest_length=0         
declare -a longest_lines 
function analyze_file() {
	local filepath="$1"  
	local line_counter=1 
	if [ "$filepath" == "-" ]; then
		input_source="/dev/stdin"
	else
		input_source="$filepath"
	fi
	while IFS= read -r line; do
		local line_length=${#line} # Get the length of the line.
		if ((line_length > longest_length)); then
			longest_length=$line_length
			longest_lines=("$filepath: $line_counter $line_length $line")
		elif ((line_length == longest_length)); then
			longest_lines+=("$filepath: $line_counter $line_length $line")
		fi
		((line_counter++))   
	done <"$input_source" 
}
for item in "${@:-"-"}"; do
	if [ "$item" == "-" ]; then
		item="/dev/stdin"
	fi
	if [ "$item" == "/dev/stdin" ]; then
		analyze_file "-"
	elif [ -f "$item" ]; then
		analyze_file "$item"
	elif [ -d "$item" ]; then
		while IFS= read -r found_file; do
			analyze_file "$found_file"
		done < <(find "$item" -type f)
	else
		echo "Error: '$item': File or directory does not exist" >&2
	fi
done
for output_line in "${longest_lines[@]}"; do
	echo "Result: '$output_line'"
done

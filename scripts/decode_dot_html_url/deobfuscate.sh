#! /bin/bash

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

cleaned_js_filename="${1%.*}.cleaned.js"
input_filename_extension="${1##*.}"
js_from_html_filename="${1%.*}.js"


if [[ $input_filename_extension == *"htm"* ]]; then
	# parses out JavaScript from HTML file and then deobfuscates
	grep -oP '(?<=>).*(?=</script>)' $1 > $js_from_html_filename
	synchrony deobfuscate $js_from_html_filename &>/dev/null
	rm $js_from_html_filename
else
	# deobfuscates passed js
	synchrony deobfuscate $1 &>/dev/null
fi

# parse out string that contains URL
cat $cleaned_js_filename |  grep -oP "'.*'" | while read -r line ; do
		data=$(urldecode $line)
		if [[ $data == *"http"* ]]; then
			echo $data
		fi
done

rm $cleaned_js_filename

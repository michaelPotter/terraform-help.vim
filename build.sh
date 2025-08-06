#!/usr/bin/env bash
#
# build.sh
#
# Michael Potter
# 2025-08-06

version="v1.12.x"

[[ -d web-unified-docs ]] || git clone https://github.com/hashicorp/web-unified-docs --depth 1

cat /dev/null > doc/tags
tag() {
	name="$1"
	printf '%s\tterraform-functions.txt\t/*%s*\n' "$name" "$name" >> doc/tags
}
tag "terraform-functions.txt"

# Send all stdout to the help file
exec > doc/terraform-functions.txt

echo "*terraform-functions.txt*                            Terraform version ${version}"

# TODO add table of contents
# ==============================================================================
# Table of Contents                      *terraform-functions-table-of-contents*

# TODO add some sections that group the functions by type like the website sidebar (e.g. numeric, string, collection, etc.)

in_quote=false
for f in web-unified-docs/content/terraform/$version/docs/language/functions/* ; do
	# Build the tag name
	function=$(basename "$f" .mdx)
	tag="terraform-function-$function"

	# Add it to the tags file
	tag "$tag"

	# Create a "header" line with the tag
	echo ""
	echo "================================================================================"
	printf "${function@U}%80s\n" "*$tag*"
	echo ""
	echo "https://developer.hashicorp.com/terraform/language/functions/$function"
	echo ""

	# Print the documentation... the format could be improved
	cat $f | while IFS="\n" read -r line; do
		if $in_quote ; then
			if [[ "$line" =~ ^\`\`\` ]] ; then # closing quoted section
				in_quote=false
				echo "${line/\`\`\`/\<}"
			else
				echo "    $line" # Indent a quoted line
			fi

		else
			if [[ "$line" =~ ^\`\`\` ]] ; then # open quoted section
				in_quote=true
				echo "${line/\`\`\`/\>}"
			else
				echo "$line" # Default line handler
			fi
		fi
	done
done

echo 'vim:tw=78:ts=8:noet:ft=help:norl:'

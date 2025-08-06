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

# ==============================================================================
# Table of Contents                      *terraform-functions-table-of-contents*

for f in web-unified-docs/content/terraform/$version/docs/language/functions/* ; do
	# Build the tag name
	function=$(basename "$f" .mdx)
	tag="terraform-function-$function"

	# Add it to the tags file
	tag "$tag"

	# Create a "header" line with the tag
	echo ""
	printf "${function@U}%80s\n" "*$tag*"
	echo ""
	echo "https://developer.hashicorp.com/terraform/language/functions/$function"
	echo ""

	# Print the documentation... the format could be improved
	cat $f
done

echo 'vim:tw=78:ts=8:noet:ft=help:norl:'

#!/bin/sh

if ! [ -f "$1" ]; then
	exit 0
fi

width=80
prefix=Documentation/
here=$(pwd)

if [ "$(basename \"$here\")" = 'Documentation' ]; then
	prefix=
fi

fn="$1"
bn=$(basename "$fn" .rst)
man=$(find ${prefix}_build/man -name "$bn".'[0-9]')

cat << EOF
<details>
<summary>$fn</summary>

\`\`\`
EOF

COLUMNS="$width" man -P cat "$man"

cat << EOF
\`\`\`

</details>
EOF

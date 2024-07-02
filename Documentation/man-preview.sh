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

if [ "$bn" = 'btrfs-man5' ]; then
	# This is the only page that does not follow from the file name,
	# the translation could be done using the man_pages table in conf.py
	# but for one entry let's add a exception here
	man="${prefix}_build/man/btrfs.5"
else
	man=$(find "${prefix}"_build/man -name "$bn".'[0-9]')
fi

if ! [ -f "$man" ]; then
	echo "ERROR: cannot find manual page '$man' from bn $bn fn $fn <br/>"
	exit 0
fi

cat << EOF
<details>
<summary>$fn</summary>

\`\`\`
EOF

COLUMNS="$width" man -P cat --html=cat "$man" | awk '
/^<body>/ { doit=1; next; }
/^<\/body>/ { doit=0; next; }
doit==1 { print; }'

cat << EOF
\`\`\`

</details>
EOF

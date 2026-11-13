#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-10-31 01:35:01 +0900 (Sat, 31 Oct 2026)
#
#  https///github.com/HariSekhon/DevOps-Bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090,SC1091
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Dumps the GNU Screen copy buffer contents to stdout

First use the standard Ctrl-[ mode to select the text to copy into the Screen copy buffer

Retains the temp file if this environment variable is set to any value:

    export SCREEN_BUFFER_NO_DELETE_TEMPFILE=1

Used by adjacent script:

    screen_buffer_to_clipboard.sh
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

# indicate to screen_terminal_to_stdout.sh not to remove the term
export SCREEN_TERMINAL_NO_DELETE_TEMPFILE=1

tmpfile="$(mktemp)"

if [ -z "${SCREEN_BUFFER_NO_DELETE_TEMPFILE:-}" ]; then
    trap_cmd "rm -f \"$tmpfile\""
else
    timestamp "Dumping GNU Screen copy buffer contents to tempfile: $tmpfile"
    echo >&2
fi

screen -X writebuf "$tmpfile"

cat "$tmpfile"

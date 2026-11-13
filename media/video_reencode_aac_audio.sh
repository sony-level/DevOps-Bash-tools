#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-10-31 00:25:50 +0900 (Sat, 31 Oct 2026)
#
#  https://github.com/HariSekhon/DevOps-Bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback to help steer this or other code I publish
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
Converts one or more video files to use the more compatible AAC audio format using ffmpeg

Necessary to upload to social media sites like X that don't accept audio formats like Opus (used in YouTube videos)

Tested on .mp4 files

Names the generated files the same except with the file extension replaced with '.aac.mp4'

Opens the video upon completion to check it unless environment variable NO_VIDEO_OPEN is set to any value

Skips files which already have a corresponding adjacent '.aac.mp4' file for safety

Removes partially complete files for consistency using bash trapping

Installs ffmpeg using OS package manager if not already installed
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<video_files>"

help_usage "$@"

min_args 1 "$@"

if ! type -P ffmpeg &>/dev/null; then
    timestamp "ffmpeg not found in \$PATH, attempting to install..."
    echo
    "$srcdir/../packages/install_packages.sh" ffmpeg
    echo
fi

check_bin ffmpeg

SECONDS=0

FFMPEG_LOGLEVEL="${FFMPEG_LOGLEVEL:-info}"

time \
for filepath in "$@"; do
    if ! [[ "$filepath" =~ ^\.*/ ]]; then
        filepath="./$filepath"
    fi
    new_mp4_filepath="${filepath%.*}.aac.mp4"
    if [ -s "$new_mp4_filepath" ]; then
        timestamp "File already exists, skipping: $new_mp4_filepath"
    else
        # shellcheck disable=SC2016
        trap_cmd 'echo; echo "removing partially done file:"; rm -fv -- "$new_mp4_filepath"; untrap'
        timestamp "converting $filepath => $new_mp4_filepath"
        time ffmpeg -i "$filepath" \
                    -loglevel "$FFMPEG_LOGLEVEL" \
                    -c:v copy \
                    -c:a aac \
                    -b:a 192k \
                    -ar 48000 \
                    -ac 2 \
                    -movflags +faststart \
                    -- "$new_mp4_filepath"
        echo >&2
    fi
    if is_blank "${NO_VIDEO_OPEN:-}"; then
        "$srcdir/vidopen.sh" "$new_mp4_filepath"
    fi
done

echo >&2
timestamp "All conversions completed in $SECONDS secs"
untrap

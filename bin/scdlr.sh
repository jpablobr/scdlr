#!/bin/sh

# `scdlr.sh`, SoundCloud tracks downloader.

set -e

# Load the `scdlr` function and its friends.  These are assumed to be
# in the `lib` directory in the same tree as this `bin` directory.
. "$(dirname "$(dirname "$0")")/lib/scdlr.sh"

# Call `scdlr` with the required options to start the downloads.
scdlr

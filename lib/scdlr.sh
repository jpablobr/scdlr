#!/bin/sh

# **scdlr.sh**, SoundCloud tracks downloader.

# scdlr.sh
#
# Copyright (C) 2011  Jose Pablo Barrantes
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


# Usage and Prerequisites
# -----------------------

# Installation
# -----------------------

# `git clone https://github.com/jpablobr/scdlr.git`

# `cd scdlr`

# `make && sudo make install`

# Usage
# -----------------------
# From the command-line:

# Append a URL to the download.list

# `$ scdlr.sh -a URL`

# Download all URLs on the download.list

# `$ scdlr.sh -s`

set -e

# Program base name.
PROGNAME=$(basename $0)

# `SCDLR_PATH` is the path where all the tracks will be downloaded.
# It can also be set in the environment.
SCDLR_PATH=${SCDLR_PATH:-'~/Music/Soundcloud'}

# This is the download.list (`ARTISTS_LIST`) with all the DJs accounts
# URLs.

#     CODE http://soundcloud.com/bassbintwins
#     CODE http://soundcloud.com/bassnectar
#     CODE # http://soundcloud.com/dirty-talk
#     CODE # http://soundcloud.com/funckarma
#     ...

# Notice it's also possible in the `ARTISTS_LIST` to *comment* out DJs
# that already been downloaded but do not wish to remove them from the
# list because maybe later on you'll want to re-download their
# music... Though, `Curl(1)` will handle all the download `resuming`
# functionality anyway! :).
ARTISTS_LIST="$SCDLR_PATH/soundcloud.list"

# Function for exit due to fatal program error
# string containing descriptive error message
die() {
    local err_msg="${PROGNAME} ${1}"
    _print_error ${err_msg} >&2
    exit 1
}

# Helpers
# -------

# Helpers for printing to `standard output`.
_print_info () {
    printf "$(tput setaf 2)[I]$(tput op) $1\n" >&2
}

_print_error () {
    printf "$(tput setaf 1)[E]$(tput op) $1\n" >&2
}

_print_warning () {
    printf "$(tput setaf 3)[W]$(tput op) $1\n" >&2
}

_print_help () {
    printf "$(tput setaf 7)[H]$(tput op) $1\n" >&2
}

_print_section () {
    printf "\n$(tput setaf 5)###$(tput op) $1\n" >&2
}

# Usage
# -----
usage() {
    echo; _print_info " usage: ${PROGNAME} [-a or -s] [URL]"

    cat <<USAGE
    Examples:
    # Append a URL to the download.list
    ${PROGNAME} -a URL

    # Download all URLs on the download.list
    ${PROGNAME} -s

    Download list path:
    $(tput setaf 2)${ARTISTS_LIST}$(tput op)

    See also:
    curl(1)
USAGE

    die
}

# Validate that at least one argument is provided.
[ "$#" -lt 1 ] && usage

# If a URL is supplied given via the `-a` argument it will be added to
# the download list. Later on maybe this should validate if the url is
# already there and also check if it already has has been downloaded.
append_to_downloads_list() {
    echo $url >>$ARTISTS_LIST
    tput setaf 4; cat $ARTISTS_LIST; tput op
    exit
}

artist_pages() {
    curl -s --user-agent 'Mozilla/5.0' "$1/tracks" |
    grep "tracks?page="                            |
    tr '=' '\n'                                    |
    sed 's/[^1-9>]//g'                             |
    tr '>' '\n'                                    |
    sort -u                                        |
    tail -1
}

artist_songs() {
    echo "$1"        |
    grep 'streamUrl' |
    tr '"' "\n"      |
    grep 'http://media.soundcloud.com/stream/'

}

artist_song_count() {
    echo $1 | wc -l
}

song_titles() {
    echo "$1"       |
    grep 'title":"' |
    tr ',' "\n"     |
    grep 'title'    |
    cut -d '"' -f 4
}

song_title(){
    echo -e "$1"            |
    sed -n "$2"p            |
    tr ' ' '_'              |
    tr -d '[{}(),\\!;:#+*]' |
    tr -d "\'"              |
    tr '[A-Z]' '[a-z]'      |
    sed -e 's:.*/::'        \
        -e 's/[-\.]/_/g'    \
        -e 's:[_]\+:_:g'    \
        -e 's:&amp::g'      \
        -e 's:&quot::g'     \
        -e 's:-[0-9].*::'
}

artist_page_count(){
    if [ "$1" = "1" ]; then
        curl -s --user-agent 'Mozilla/5.0' "$2"
    else
        curl -s --user-agent 'Mozilla/5.0' "$2/tracks?page=$3"
    fi
}

# Process each of the DJs URLs to download all their tracks.
download_tracks() {
   # Amount of pages the DJ has in his profile. Will also be used
   # in the `download_by_artist` function to *crawl* his account.

    pages=$(artist_pages "$1")

    [ -z "$pages" ] && pages=1

    _print_info "Found $pages pages of songs!"

    # `curl` to identify the amount of pages in order to build the
    # individual URLs.
    for page in $(seq 1 $pages); do

        this=$(artist_page_count "$pages" "$1" "$page")
        songs=$(artist_songs "$this")
        songcount=$(artist_song_count $songs)
        titles=$(song_titles "$this")

        [ -z "$songs" ] && die "No song found at $1/tracks?page=$page."

        _print_info "Downloading $songcount songs from page $page."

        # Build the URL and `curl` it
        for songid in $(seq 1 ${songcount}); do
            title=$(song_title "$titles" "$songid")
            url=$(echo "$songs" | sed -n "$songid"p)
            # Since (and for good messure) the script uses `set -e` it will
            # exit on error exit status. The problem is that soundcloud do not
            # support byte ranges which makes `curl` exit with a 33 error
            # forcing the script to terminate. The `|| true` statment will
            # allow the script to continue to download the rest of the songs.
            curl -C - -L --user-agent 'Mozilla/5.0' -o "$title.mp3" "$url" || true
            _print_info "Track $title downloaded with an exit status of: $?"
        done
    done
}

# Parse the download.list to create a directory for each of the DJs
# (to keep them organized).
start_downloads() {
    while read url; do
        # Check for # char in order to label the url as commented out.
        # Help to keep URLs in `$download_list` without having to
        # delete them.
        echo "$url" | grep -q '^#' && continue

        cd $SCDLR_PATH || die

        new_dir=$(echo "$url" | sed -e 's/.*\///g')

        if [ -d $SCDLR_PATH/$new_dir ]; then
            # Curl will determine if the tracks has been downloaded.
            cd "./$new_dir"
            _print_info "Changing directory to: $new_dir"
        else
            _print_info "Creating $new_dir directory."
            mkdir "./$new_dir" && cd "./$new_dir"
        fi
        _print_section "Downloading tracks from $new_dir"
        download_tracks "$url"
    done <$ARTISTS_LIST
    exit
}

# User options:
#
# `-s` will parse the download.list and start processing each of the
# DJs accounts.

# `-a` will require a DJ account URL and it will be added to the
# download.list.

[ "$1" = "--help" ] && usage

while getopts "a:s" opt; do
    case $opt in
        a ) append_to_download_list $OPTARG
            ;;
        s ) start_downloads
            ;;
        h ) helptext
            ;;
        * ) usage
            exit 1
    esac
done

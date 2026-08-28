#!/bin/bash
set -euo pipefail

# Usage:
#
#   Fetch entire library:
#     fetch_album_lyrics.sh "/path/to/Music"
#
#   Fetch entire library except selected artists:
#     fetch_album_lyrics.sh "/path/to/Music" --exclude "Artist 1" "Artist 2"
#
#   Use a separate LRC directory:
#     fetch_album_lyrics.sh "/path/to/Music" "/path/to/LRC"
#
#   Separate LRC directory + exclusions:
#     fetch_album_lyrics.sh "/path/to/Music" "/path/to/LRC" --exclude "Artist 1"
#
#
# Expected structure:
#
# Music/
# ├── Category/
# │   ├── Artist/
# │   │   ├── Single.mp3
# │   │   └── Album/
# │   │       ├── Track.mp3
# │   │       └── Track 2.mp3
# │   │
# │   └── Another Artist/
# │       └── Album/
# │           └── Track.mp3
# │
# └── Another Category/
#     └── Artist/
#         └── Album/
#             └── Track.mp3


LRCLIB_API="https://lrclib.net/api/get"


# ==================================================
# Arguments
# ==================================================

if [ $# -lt 1 ] || [ $# -gt 100 ]; then
    echo "Usage:"
    echo "  $0 \"/path/to/Music\""
    echo "  $0 \"/path/to/Music\" --exclude \"Artist 1\" \"Artist 2\""
    echo "  $0 \"/path/to/Music\" \"/path/to/LRC\""
    echo "  $0 \"/path/to/Music\" \"/path/to/LRC\" --exclude \"Artist 1\""
    exit 1
fi


MUSIC_DIR="${1%/}"

if [ ! -d "$MUSIC_DIR" ]; then
    echo "Error: '$MUSIC_DIR' is not a directory."
    exit 1
fi

# Convert relative path to absolute without resolving symlinks
if [[ "$MUSIC_DIR" != /* ]]; then
    MUSIC_DIR="$PWD/$MUSIC_DIR"
fi


# ==================================================
# Options
# ==================================================

USE_EXTERNAL_OUTPUT=false
OUTPUT_DIR=""
EXCLUDE_ARTISTS=()


shift

while [ $# -gt 0 ]; do

    case "$1" in

        --exclude)

            shift

            if [ $# -eq 0 ]; then
                echo "Error: --exclude requires at least one artist."
                exit 1
            fi

            while [ $# -gt 0 ]; do
                EXCLUDE_ARTISTS+=("$1")
                shift
            done

            ;;

        --help|-h)

            echo "Usage:"
            echo "  $0 \"/path/to/Music\""
            echo "  $0 \"/path/to/Music\" --exclude \"Artist 1\" \"Artist 2\""
            echo "  $0 \"/path/to/Music\" \"/path/to/LRC\""
            echo "  $0 \"/path/to/Music\" \"/path/to/LRC\" --exclude \"Artist 1\""
            exit 0
            ;;

        *)

            if [ "$USE_EXTERNAL_OUTPUT" = false ]; then

                USE_EXTERNAL_OUTPUT=true
                OUTPUT_DIR="${1%/}"

                if [[ "$OUTPUT_DIR" != /* ]]; then
                    OUTPUT_DIR="$PWD/$OUTPUT_DIR"
                fi

                shift

            else

                echo "Error: Unknown argument '$1'"
                exit 1

            fi

            ;;

    esac

done


# ==================================================
# Check if artist is excluded
# ==================================================

is_excluded() {
    local artist="$1"

    local excluded

    for excluded in "${EXCLUDE_ARTISTS[@]}"; do

        if [[ "$artist" == "$excluded" ]]; then
            return 0
        fi

    done

    return 1
}


# ==================================================
# Fetch lyrics from LRCLIB
# ==================================================

get_lyrics_for() {
    local artist="$1"
    local album="$2"
    local title="$3"

    curl -sG \
        --data-urlencode "artist_name=$artist" \
        --data-urlencode "track_name=$title" \
        --data-urlencode "album_name=$album" \
        "$LRCLIB_API" |
        jq -r '.syncedLyrics // empty'
}


# ==================================================
# Fetch lyrics with fallback
# ==================================================

fetch_for_plain() {
    local artist="$1"
    local album="$2"
    local title="$3"
    local out_lrc="$4"

    local lyrics

    # First attempt
    lyrics="$(get_lyrics_for "$artist" "$album" "$title")"

    # Retry without (...) from title
    if [ -z "$lyrics" ]; then

        local stripped

        stripped="$(
            printf '%s' "$title" |
                sed -E 's/ *\([^)]*\)//g'
        )"

        if [ "$stripped" != "$title" ]; then
            lyrics="$(get_lyrics_for "$artist" "$album" "$stripped")"
        fi

    fi

    # No lyrics
    if [ -z "$lyrics" ]; then
        echo "    ✗ No lyrics found"
        return 1
    fi

    # Only create the directory when lyrics exist
    mkdir -p "$(dirname "$out_lrc")"

    # Remove optional metadata
    printf '%s\n' "$lyrics" |
        sed -E '/^\[(ar|al|ti):/d' > "$out_lrc"

    echo "    ✔ Saved: $out_lrc"
}


# ==================================================
# Get LRC output path
# ==================================================

get_lrc_path() {
    local mp3="$1"

    # ----------------------------------------------
    # Default:
    # Save beside MP3
    # ----------------------------------------------

    if [ "$USE_EXTERNAL_OUTPUT" = false ]; then
        printf '%s\n' "${mp3%.mp3}.lrc"
        return
    fi


    # ----------------------------------------------
    # External output:
    # Preserve the complete library structure
    # ----------------------------------------------

    local relative_path

    relative_path="${mp3#"$MUSIC_DIR"/}"
    relative_path="${relative_path%.mp3}"

    printf '%s\n' "$OUTPUT_DIR/$relative_path.lrc"
}


# ==================================================
# Process one MP3
# ==================================================

process_mp3() {
    local artist="$1"
    local album="$2"
    local mp3="$3"

    local title
    local lrc_file

    title="$(basename "$mp3" .mp3)"

    lrc_file="$(get_lrc_path "$mp3")"


    # Don't overwrite existing lyrics
    if [ -f "$lrc_file" ]; then
        echo "    – $title (already exists)"
        return
    fi


    echo "    → $title"
    echo "      Album: $album"

    fetch_for_plain \
        "$artist" \
        "$album" \
        "$title" \
        "$lrc_file" || true
}


# ==================================================
# Process one artist
# ==================================================

process_artist() {
    local artist_dir="$1"

    local artist

    artist="$(basename "$artist_dir")"


    # ----------------------------------------------
    # Exclusion
    # ----------------------------------------------

    if is_excluded "$artist"; then
        echo
        echo "⏭ Skipping excluded artist: $artist"
        return
    fi


    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎤 Artist: $artist"
    echo "📂 $artist_dir"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"


    # ----------------------------------------------
    # Find ALL MP3s recursively
    # ----------------------------------------------

    while IFS= read -r -d '' mp3; do

        local mp3_dir
        local relative_path
        local album

        mp3_dir="$(dirname "$mp3")"


        # ------------------------------------------
        # Single
        #
        # Artist/
        # └── Song.mp3
        # ------------------------------------------

        if [ "$mp3_dir" = "$artist_dir" ]; then

            album="$(basename "$mp3" .mp3)"


        # ------------------------------------------
        # Album
        #
        # Artist/
        # └── Album/
        #     └── Song.mp3
        #
        # For deeper structures:
        #
        # Artist/
        # └── Album/
        #     └── Disc 1/
        #         └── Song.mp3
        #
        # Album is still "Album".
        # ------------------------------------------

        else

            relative_path="${mp3#"$artist_dir"/}"

            album="${relative_path%%/*}"

        fi


        process_mp3 "$artist" "$album" "$mp3"

    done < <(
        find -L "$artist_dir" \
            -type f \
            -iname "*.mp3" \
            -print0
    )
}


# ==================================================
# Start
# ==================================================

echo
echo "▶ Music Lyrics Fetcher"
echo
echo "  Music: $MUSIC_DIR"

if [ "$USE_EXTERNAL_OUTPUT" = true ]; then
    echo "  LRC:   $OUTPUT_DIR"
else
    echo "  LRC:   beside tracks"
fi


# ==================================================
# Show exclusions
# ==================================================

if [ "${#EXCLUDE_ARTISTS[@]}" -gt 0 ]; then

    echo
    echo "  Excluded artists:"

    for artist in "${EXCLUDE_ARTISTS[@]}"; do
        echo "    - $artist"
    done

fi

echo


# ==================================================
# Scan categories
# ==================================================

ARTIST_COUNT=0
SKIPPED_COUNT=0


while IFS= read -r -d '' category_dir; do

    category="$(basename "$category_dir")"


    echo
    echo "════════════════════════════════════"
    echo "📁 Category: $category"
    echo "════════════════════════════════════"


    # Artist folders are directly inside categories
    while IFS= read -r -d '' artist_dir; do

        artist="$(basename "$artist_dir")"


        if is_excluded "$artist"; then

            echo
            echo "⏭ Excluded: $artist"

            ((SKIPPED_COUNT++)) || true

            continue
        fi


        process_artist "$artist_dir"

        ((ARTIST_COUNT++)) || true

    done < <(
        find -L "$category_dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -print0
    )


done < <(
    find -L "$MUSIC_DIR" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -print0
)


# ==================================================
# Done
# ==================================================

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Done."
echo
echo "Artists processed: $ARTIST_COUNT"
echo "Artists skipped:   $SKIPPED_COUNT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

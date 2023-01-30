#!/bin/bash

# dependencies: rofi, jq, brave, sqlite3

# decide if the browser should be open in a new instance or not
while getopts 'tw' OPTION; do
	case "$OPTION" in
	w)
		BRAVE_ARGS="--new-window"
		BRAVE_DISPLAY_TEXT="brave (window): "
		;;
	t)
		BRAVE_ARGS="--new-tab"
		BRAVE_DISPLAY_TEXT="brave (tab): "
		;;
	?)
		echo "script usage: $(basename "$0") [-n] [-e]" >&2
		exit 1
		;;
	esac
done

shift "$((OPTIND - 1))"

ROOT_BRAVE_PATH="$HOME/.config/BraveSoftware/Brave-Browser"

BOOKMARKS="$ROOT_BRAVE_PATH/Default/Bookmarks"

SEPARATOR="XXXXXXXXXXXXXXXXXXXX"

readarray -t BOOKMARK_NAME < <(jq '.roots.bookmark_bar.children[].name' \
	"$BOOKMARKS")

readarray -t BOOKMARK_URL < <(jq '.roots.bookmark_bar.children[].url' \
	"$BOOKMARKS")

declare -A BOOKMARKS
for i in "${!BOOKMARK_NAME[@]}"; do
	BOOKMARKS["${BOOKMARK_NAME[$i]}"]="${BOOKMARK_URL[$i]}"
done

unset "BOOKMARKS[0]"

HISTORY_DB="$ROOT_BRAVE_PATH/Default/History"

# # now we add the history selection
SQL="SELECT u.title, u.url FROM urls as u WHERE u.url LIKE 'https%' ORDER BY visit_count DESC;"
histlist=$(printf '%s\n' "$(sqlite3 "file:$HISTORY_DB?mode=ro&nolock=1" "$SQL")" |
	awk -F "|" '{print $1" # "$NF} ')

choice=$(
	printf '%s\n' \
		"$SEPARATOR" "$histlist" \
		"$SEPARATOR" "${!BOOKMARKS[@]}" |
		rofi -normalize-match -dmenu -i -l 9 -p \
			"$BRAVE_DISPLAY_TEXT"
)

if [[ "$choice" = "$SEPARATOR" ]]; then
	brave "$BRAVE_ARGS"

elif [[ "$choice" =~ .*'#'.* ]]; then
	url=$(echo "$choice" | awk '{print $NF}') || exit
	brave "$BRAVE_ARGS" "$url"

elif [[ ${BOOKMARKS["$choice"]} ]]; then
	url=$(echo "${BOOKMARKS[$choice]}" | sed 's/"//g') || exit
	brave "$BRAVE_ARGS" "$url"

elif [[ "$choice" == "!"* ]]; then
	SEARCH_ENG=$(echo "$choice" | cut -d' ' -f1)
	SEARCH_QUERY=$(echo "$choice" | cut -d' ' -f2-)

	case "$SEARCH_ENG" in
	!g)
		brave "$BRAVE_ARGS" "https://www.google.com/search?hl=en&q=$SEARCH_QUERY"
		;;
	!gt)
		brave "$BRAVE_ARGS" "https://translate.google.com/?sl=auto&tl=en&text=$SEARCH_QUERY &op=translate"
		;;
	!mt)
		brave "$BRAVE_ARGS" "https://math.stackexchange.com/search?q=$SEARCH_QUERY"
		;;
	!yt)
		brave "$BRAVE_ARGS" "https://www.youtube.com/results?search_query=$SEARCH_QUERY"
		;;
	!aw)
		brave "$BRAVE_ARGS" "https://wiki.archlinux.org/index.php?search=$SEARCH_QUERY"
		;;
	!gh)
		brave "$BRAVE_ARGS" "https://github.com/search?o=desc&q=$SEARCH_QUERY&s=stars"
		;;
	!de)
		brave "$BRAVE_ARGS" "https://www.dict.cc/?s=$SEARCH_QUERY"
		;;
	!w)
		brave "$BRAVE_ARGS" "https://en.wikipedia.org/w/index.php?search=$SEARCH_QUERY"
		;;
	!so)
		brave "$BRAVE_ARGS" "https://stackoverflow.com/search?q=$SEARCH_QUERY"
		;;
	!mw)
		brave "$BRAVE_ARGS" "https://www.merriam-webster.com/dictionary/$SEARCH_QUERY"
		;;
	!gist)
		brave "$BRAVE_ARGS" "https://gist.github.com/search?q=$SEARCH_QUERY"
		;;
	esac

elif [[ -n "$choice" ]]; then
	url="https://google.com/search?hl=en&q=$choice"
	brave "$BRAVE_ARGS" "$url"
else
	exit 0
fi

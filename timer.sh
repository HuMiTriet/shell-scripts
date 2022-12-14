#!/usr/bin/env bash
#

AUDIO_FILE="/home/pj/Music/historical_music/＂Footsteps＂ - North Korean Patriotic Song [qyWVOrgdokA].webm"

countdown() {
	start="$(($(date '+%s') + $1))"
	while [ $start -ge "$(date +%s)" ]; do
		time="$((start - $(date +%s)))"
		printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
		sleep 0.1
	done
	mpv --video=no --volume=60 --start=11 \
		--no-resume-playback "$AUDIO_FILE"
}

stopwatch() {
	start=$(date +%s)
	while true; do
		time="$(($(date +%s) - start))"
		printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
		sleep 0.1
	done
}

while getopts ":c:s" opt; do
	case $opt in
	c)
		countdown "$OPTARG"
		;;
	s)
		stopwatch
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;
	esac
done

# script must use a flag
echo "timer.sh must use a flag either -c or -s"
exit 1

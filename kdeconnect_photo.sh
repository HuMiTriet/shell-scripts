#!/usr/bin/env bash

# script to use kdeconnect to take a picture from the phone and send it to the computer

HOME="/home/pj/"
EXTENSION=".png"

# if command -v kdeconnect-cli >/dev/null 2>&1 && command -v rofi >/dev/null 2>&1; then
  # CHOSEN_DEVICE_ID=$(kdeconnect-cli -a --id-name-only | \
  #    rofi -dmenu -i -p \
  # "Select device: " | awk '{print $1}')

  CHOSEN_DEVICE_ID=$(kdeconnect-cli -a --id-only)

  if [[ -n "$CHOSEN_DEVICE_ID" ]]; then
    FILE_NAME=$(rofi -dmenu -i -p "finame: ")

    if [[ -f "$HOME$FILE_NAME$EXTENSION" ]]; then
      ANSWER=$(rofi -dmenu -i -p "File exists. Overwrite? (y/n): ")
      if [[ $ANSWER =~ ^[Yy]$ ]]; then
        rm "$HOME$FILE_NAME$EXTENSION"
      else 
        exit 3
      fi
    fi

    if [[ -n "$FILE_NAME$EXTENSION" ]]; then 
      echo  "$HOME$FILE_NAME$EXTENSION"
      kdeconnect-cli -d "$CHOSEN_DEVICE_ID" --photo "$HOME$FILE_NAME$EXTENSION"
    else 
      exit 2
    fi
  else 
    exit 1
  fi


# else
#   echo "kdeconnect-cli or rofi can't be found. \
#   Install it on (arch based) using pacman -S kdeconnect and pacman -S rofi"
# fi

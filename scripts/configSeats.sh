#!/bin/bash

seatnum=0
while true
do
  taken=false;
  for i in $(swaymsg -t get_seats | jq -r '.[].name');
  do
    if [ "seat$seatnum" == "$i" ]
    then
      taken=true
      break
    fi
  done
  if $taken
  then
    ((seatnum++))
  else
    break
  fi
done
echo "seat$seatnum"

devices=$(zenity --list \
  --title="Device chooser" \
  --text="Select devices for seat$seatnum. Multiple devices can be selected by holding ctrl key" \
  --column=device \
  --separator=' ' \
  --multiple \
  $(swaymsg -t get_seats | \
    jq -r '.[] | select(.name =="seat0").devices.[].identifier'))

for device in $devices
do
  if [ "$1" == "--print" ]
  then
    echo swaymsg seat "seat$seatnum" attach $device
  else
    swaymsg seat "seat$seatnum" attach $device
  fi
done

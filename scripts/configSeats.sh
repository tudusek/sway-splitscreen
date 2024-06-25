#!/bin/bash

seatnum=0
while true
do
  taken=false;
  seats=$(swaymsg -t get_seats | jq -r '.[].name')
  for i in $seats;
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

inputs=$(swaymsg -t get_inputs)
devices=$(zenity --list \
  --title="configSeat" \
  --text="Select devices for seat$seatnum. Multiple devices can be selected by holding ctrl key" \
  --column=device \
  --separator=' ' \
  --multiple \
  $(swaymsg -t get_seats | \
    jq -r '.[] | select(.name =="seat0").devices.[].identifier' | uniq))

if [ "$devices" == "" ]; then
  exit
fi

outputs=$(swaymsg -t get_outputs)
output=$(zenity --forms \
  --title="configSeat" \
  --text="Constrain pointer to output" \
  --add-combo="output" \
  --combo-values="no$(echo $outputs | 
    swaymsg -t get_outputs | jq -r '.[].name' |
    awk '{printf "|"$0}')")

for device in $devices
do
  if [ "$1" == "--print" ]
  then
    if [ "$output" != "no" ]
    then
      devp=$(echo $inputs | \
        jq -r '.[] | select(.identifier == "'$device'") | select(.type == "pointer" or .type == "touchpad" ).identifier')
      if [ "$device" == "$devp" ]
      then
        echo swaymsg input "$device" map_to_output "$output"
      fi
    fi
    echo swaymsg seat "seat$seatnum" attach "$device"
  else
    if [ "$output" != "no" ]
    then
      devp=$(echo $inputs | \
        jq -r '.[] | select(.identifier == "'$device'") | select(.type == "pointer" or .type == "touchpad" ).identifier')
      if [ "$device" == "$devp" ]
      then
        swaymsg input "$device" map_to_output "$output"
      fi
    fi
    swaymsg seat "seat$seatnum" attach "$device"
  fi
done

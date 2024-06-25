#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
layout=$(zenity --forms \
  --title='splitLauncher' \
  --text="Enter layout" \
  --add-entry=rows \
  --add-entry=columns \
  --separator=' ')

rows=$(echo $layout | awk '{print $1}')
columns=$(echo $layout | awk '{print $2}')

if ! [[ $rows =~ ^[0-9]+$ ]] ; then
  zenity --info --text='error: Not a number'
  exit
fi
if ! [[ $columns =~ ^[0-9]+$ ]] ; then
  zenity --info --text='error: Not a number'
  exit
fi

#Setup xwaylands
for ((i=1;i<=columns;i++)); do
  for ((j=1;j<=rows;j++));do
    # Xwayland -noreset :$x &
    $SCRIPT_DIR/newPlayer.sh &
    ((x++))
    sleep 0.5s
    if ((j == 1 && i != 1));then
      swaymsg move right
    fi
    sleep 0.2s
    if((j == 1));then
      swaymsg splitv
    fi
  done
done
wait
cleanup

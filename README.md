# Scripts for setting up splitscreen on Sway
![tst](https://github.com/tudusek/sway-splitscreen/assets/112270296/29f79d02-d42a-4abd-8515-1ef0fd09eaa9)
## Requirements:
  - sway
  - jq
  - zenity
  - for splitLauncher:
    - Xwayland
    - bwrap
    - xfwm4
    - fuse-overlayfs (optional)
    - hsetroot (optional, for colored background)

## configSeats.sh
Creates new seat and assigns device(s) to it.

## generateSeatConfig.sh
Prints commands to recreate current seats configuration.

## splitLauncher.sh
Sets up splitscreen in specifed layout and starts the aplication.
There are two modes:
  - flatpak
  - bwrap
    - creates isolated enviroment for each player and launches specifed command in it

In both cases it creates by default home folder for each player in ~/bwrap. You can change the path by editing variable `homeDir` in the script.

## screenshots

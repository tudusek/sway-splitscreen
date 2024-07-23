# Scripts for setting up splitscreen on Sway
![script showcase](https://github.com/tudusek/sway-splitscreen/assets/112270296/29f79d02-d42a-4abd-8515-1ef0fd09eaa9)
## Requirements:
  - sway
  - jq
  - zenity
  - for splitLauncher:
    - Xwayland
    - bwrap
    - xfwm4
    - fuse-overlayfs (optional)
    - hsetroot (not working for now, for colored background)

## configSeats.sh
Creates new seat and assigns device(s) to it.
Sometimes your input device might be shown as multiple devices. To avoid issues select all of them.

## generateSeatConfig.sh
Prints commands to recreate current seats configuration.

## splitLauncher.sh
Launches newPlayer.sh in specified layout.

## newPlayer.sh
Launches Xwayland rootful with xfwm4, shows player selection dialog and starts the program/game.
There are two modes:
  - flatpak
  - bwrap
    - creates isolated enviroment for player and launches specifed command in it
    - binds player home dir on $HOME

In both cases it creates by default home folder for each player in ~/bwrap. You can change the path by editing variable `homeDir` in the script.

## screenshots
### Mindustry flatpak version
![Mindustry flatpak](https://github.com/tudusek/sway-splitscreen/assets/112270296/de4379e0-748a-4490-8723-9930fac3b597)

### Team Fortress 2
using bwrap mode on local server with vac disabled
![TF2 Steam bwrap](https://github.com/user-attachments/assets/d0963c56-b0e0-4d0a-8766-e5340e2c1a30)

### Fortninte (v8.51)
Fortnite v8.51 running with wine using my fork wine_injector to inject dlls from reboot launcher. LawinServer and Windows vm with server launched via reboot launcher running in background.
![fn](https://github.com/user-attachments/assets/af0e6584-5b47-4110-b255-dced2888058f)

#!/bin/bash

# Define variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

# Set the script to exit on error
set -e

printf "$(tput setaf 2) Welcome to Hyprland installer!\n $(tput sgr0)"

sleep 2

printf "$YELLOW PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!
This script will overwrite some of your configs and files!"

sleep 2

printf "\n
$YELLOW  Some commands requires you to enter your password inorder to execute
If you are worried about entering your password, you can cancel the script now with CTRL Q or CTRL C and review contents of this script. \n"

sleep 3

# Check if yay is installed
ISyay=/sbin/yay

if [ -f "$ISyay" ]; then
    printf "\n%s - yay was located, moving on.\n" "$GREEN"
else 
    printf "\n%s - yay was NOT located\n" "$YELLOW"
    read -n1 -rep "${CAT} Would you like to install yay (y,n)" INST
    if [[ $INST =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin
        makepkg -frsi --noconfirm 2>&1 | tee -a $LOG
        cd ..
    else
        printf "%s - yay is required for this script, now exiting\n" "$RED"
        exit
    fi
# update system before proceed
    printf "${YELLOW} System Update to avoid issue\n" 
    yay -Syu --noconfirm 2>&1 | tee -a $LOG
fi

# Function to print error messages
print_error() {
    printf " %s%s\n" "$RED" "$1" "$NC" >&2
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "$GREEN" "$1" "$NC"
}

### Install packages ####
read -n1 -rep "${CAT} Would you like to install the packages? (y/n)" inst
echo

if [[ $inst =~ ^[Nn]$ ]]; then
    printf "${YELLOW} No packages installed. Goodbye! \n"
            exit 1
        fi

if [[ $inst =~ ^[Yy]$ ]]; then
   yay_pkgs="visual-studio-code-bin
   cava"

   hypr_pkgs="hyprland
   arc-gtk-theme
   waybar
   cliphist
   dunst
   foot
   rofi
   grim
   slurp
   imv
   brightnessctl
   polkit-kde-agent
   qt6-wayland
   qt5-wayland
   xdg-desktop-portal-hyprland
   xdg-user-dirs
   pamixer
   pipewire
   pipewire-pulse
   pipewire-audio
   wireplumber
   swaybg
   swaylock
   swayidle"


   font_pkgs="ttf-font-awesome
   ttf-jetbrains-mono
   ttf-jetbrains-mono-nerd"

   app_pkgs="python-pip
   nvim
   npm
   hugo
   android-file-transfer
   android-tools
   bluez
   bluez-utils
   fzf
   git
   htop
   imv 
   man-db
   mesa
   mesa-utils
   neofetch
   neovim
   ranger
   tlp
   zip
   unzip
   zsh
   zsh-syntax-highlighting
   zathura
   zathura-djvu
   zathura-ps
   zathura-pdf-poppler
   expac
   sc-im
   tree"

   app_pkgs2="firefox
   mpv
   thunar
   thunar-archive-plugin
   thunar-volman
   gvfs
   tumbler
   pavucontrol
   telegram-desktop" 


    if ! yay -S --noconfirm $yay_pkgs $hypr_pkgs $font_pkgs $app_pkgs $app_pkgs2 2>&1 | tee -a $LOG; then
        print_error " Failed to install additional packages - please check the install.log \n"
        exit 1
    fi

    echo
    print_success " All necessary packages installed successfully."
else
    echo
    print_error " Packages not installed - please check the install.log"
    sleep 1
fi


### Copy Config Files ###
read -n1 -rep "${CAT} Would you like to copy config files? (y,n)" CFG
if [[ $CFG =~ ^[Yy]$ ]]; then
    printf " Copying config files...\n"
 #   cp -r .config/foot ~/.config/ 2>&1 | tee -a $LOG
 #   cp -r .config/shell ~/.config/ 2>&1 | tee -a $LOG
  #  cp -r .config/swaylock ~/.config/ 2>&1 | tee -a $LOG
   
  #cp .config/background ~/.config/ 2>&1 | tee -a $LOG
  #  cp -r .config/waybar ~/.config/ 2>&1 | tee -a $LOG
  #  cp -r .config/hypr ~/.config/ 2>&1 | tee -a $LOG
   # cp -r .config/rofi ~/.config/ 2>&1 | tee -a $LOG
  #  cp -r .config/cava ~/.config/ 2>&1 | tee -a $LOG

    cp -r .config/* ~/.config/ 2>&1 | tee -a $LOG

    mkdir -p ~/.local/bin  ~/.cache/zsh 2>&1 | tee -a $LOG
    mkdir ~/Git ~/gitPackages ~/Code 2>&1 | tee -a $LOG

    cp -r .local/bin/* ~/.local/bin 2>&1 | tee -a $LOG
    cp .zshrc .zprofile .gitconfig ~ 2>&1 | tee -a $LOG

fi

# startup services
printf " Activating tlp Services...\n"
sudo systemctl enable --now tlp.service
sleep 2

### Script is done ###
printf "\n${GREEN} Installation Completed.\n"
echo -e "${GREEN} You can start Hyprland by typing Hyprland (note the capital H).\n"
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n)" HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    if command -v Hyprland >/dev/null; then
        exec Hyprland
    else
         print_error " Hyprland not found. Please make sure Hyprland is installed by checking install.log.\n"
        exit 1
    fi
else
    exit
fi

#!/bin/bash

# Void Linux GNOME Installation Script
# This script automates the installation of GNOME and various utilities on Void Linux.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting GNOME installation on Void Linux...${NC}"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (or with sudo)."
  exit 1
fi

# Detect actual user if running with sudo
REAL_USER=${SUDO_USER:-$USER}

# 1. Update system
echo -e "${BLUE}Updating system...${NC}"
xbps-install -Suv

# 2. Add non-free repository
echo -e "${BLUE}Adding void-repo-nonfree...${NC}"
xbps-install -Rs void-repo-nonfree

# 3. Install core utilities and libraries
echo -e "${BLUE}Installing core utilities and libraries...${NC}"
xbps-install -y curl wget git xz unzip zip nano vim gptfdisk xtools mtools mlocate ntfs-3g fuse-exfat bash-completion linux-headers gtksourceview4 ffmpeg mesa-vdpau mesa-vaapi htop fastfetch

# 4. Install build tools
echo -e "${BLUE}Installing build tools...${NC}"
xbps-install -y autoconf automake bison m4 make libtool flex meson ninja optipng sassc

# 5. Install Xorg
echo -e "${BLUE}Installing Xorg...${NC}"
xbps-install -y xorg

# 6. Install GDM
echo -e "${BLUE}Installing GDM...${NC}"
xbps-install -y gdm
ln -sf /etc/sv/gdm /var/service

# 7. Install XDG portal and user dirs
echo -e "${BLUE}Installing XDG portal and utils...${NC}"
xbps-install -Rs -y xdg-desktop-portal xdg-desktop-portal-gtk xdg-user-dirs xdg-user-dirs-gtk xdg-utils

# 8. Install GNOME Browser Connector
echo -e "${BLUE}Installing GNOME browser connector...${NC}"
xbps-install -y gnome-browser-connector

# 9. Install and enable D-Bus
echo -e "${BLUE}Installing and enabling D-Bus...${NC}"
xbps-install -y dbus
ln -sf /etc/sv/dbus /var/service

# 10. Install and enable elogind
echo -e "${BLUE}Installing and enabling elogind...${NC}"
xbps-install -y elogind
ln -sf /etc/sv/elogind /var/service

# 11. Install and enable NetworkManager
echo -e "${BLUE}Installing NetworkManager...${NC}"
xbps-install -y NetworkManager NetworkManager-openvpn NetworkManager-openconnect NetworkManager-vpnc NetworkManager-l2tp
ln -sfv /etc/sv/NetworkManager /var/service

# 12. Install Audio (PulseAudio)
echo -e "${BLUE}Installing PulseAudio...${NC}"
xbps-install -y pulseaudio pulseaudio-utils pulsemixer alsa-plugins-pulseaudio

# 13. Install Bluetooth
echo -e "${BLUE}Installing Bluetooth...${NC}"
xbps-install -y bluez
ln -sfv /etc/sv/bluetoothd /var/service
useradd -G bluetooth ${REAL_USER} || true

# 14. Install and enable Cronie
echo -e "${BLUE}Installing Cronie...${NC}"
xbps-install -y cronie
ln -sfv /etc/sv/cronie /var/service

# 15. Install and enable Power Management (TLP)
echo -e "${BLUE}Installing TLP...${NC}"
xbps-install -y tlp tlp-rdw powertop
ln -sfv /etc/sv/tlp /var/service

# 16. Install Fonts
echo -e "${BLUE}Installing Noto fonts...${NC}"
xbps-install -Rs -y noto-fonts-emoji noto-fonts-ttf noto-fonts-ttf-extra

# 17. Install LibreOffice
echo -e "${BLUE}Installing LibreOffice...${NC}"
xbps-install -y libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-draw libreoffice-math libreoffice-base libreoffice-gnome libreoffice-i18n-en-US

# 18. Install Flatpak
echo -e "${BLUE}Installing Flatpak...${NC}"
xbps-install -S -y flatpak

# 19. Install KDE Apps (Konsole, Dolphin) as requested
echo -e "${BLUE}Installing Konsole and Dolphin...${NC}"
xbps-install -y konsole
xbps-install -y dolphin

# 20. Install Media and Web Browser
echo -e "${BLUE}Installing MPV and Firefox...${NC}"
xbps-install -y mpv
xbps-install -y firefox firefox-i18n-en-US

# 21. Configure font rendering
echo -e "${BLUE}Configuring font rendering...${NC}"
ln -sf /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
xbps-reconfigure -f fontconfig

echo -e "${GREEN}Installation completed successfully!${NC}"

# Reboot option
read -p "Would you like to reboot the system now? (y/n): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
  echo "Rebooting..."
  reboot
else
  echo "Please reboot your system manually to apply all changes."
fi

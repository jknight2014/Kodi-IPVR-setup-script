#!/bin/bash
# Script Name: Knight couchpotato installer
# Author: Joe Knight
# Version: 0.1 initial build
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# DO NOT EDIT ANYTHING UNLESS YOU KNOW WHAT YOU ARE DOING.
clear
if (whiptail --title "CouchPotato" --yesno "Version: 0.1 (November 16, 2014) --->Couchpotato installation will start soon. Please read the following carefully. The script has been confirmed to work on Ubuntu and other Ubuntu based distros, including Mint, Kubuntu, Lubuntu, and Xubuntu. 2. While several testing runs identified no known issues, www.htpcBeginner.com or the author cannot be held accountable for any problems that might occur due to the script. 3. If you did not run this script with sudo, you maybe asked for your root password during installation." 8 78) then
    echo
else
    whiptail --title "ABORT" --msgbox "You have aborted. Please try again." 8 78
	exit 0
fi

UNAME=$(whiptail --inputbox "Enter the user you want your scripts to run as. (Case sensitive, Must exist)" 10 50 --title "System Username" 3>&1 1>&2 2>&3)

if [ ! -d "/home/$UNAME" ]; then
  whiptail --title "ABORT" --msgbox "The user you entered does not exist or does not have a home directory, Please rerun the script to try again" 8 78  
  exit 0
fi

DIR=$(whiptail --passwordbox "Enter the  directory where you would like your files saved. (/home/john would save Movies in /home/john/Movies" 10 50 /home/$UNAME --title "Storage Directory" 3>&1 1>&2 2>&3)
INDEXERHOST=$(whiptail --inputbox "Please enter your Newsnab powered Indexers hostname" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
INDEXERAPI=$(whiptail --inputbox "Please enter your Newsnab powered Indexers API key" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)

whiptail --title "COUCHPOTATO" --msgbox "Updating Apt" 8 78  
sudo apt-get update


whiptail --title "COUCHPOTATO" --msgbox "Installing Git and Python" 8 78  
sudo apt-get install git-core python


whiptail --title "COUCHPOTATO" --msgbox "Killing and version of couchpotato currently running" 8 78  
sleep 2
sudo killall couchpotato* >/dev/null 2>&1


whiptail --title "COUCHPOTATO" --msgbox "Downloading the latest version of CouchPotato" 8 78  
sleep 2
mkdir /home/$UNAME/IPVR
cd /home/$UNAME/IPVR
git clone git://github.com/RuudBurger/CouchPotatoServer.git .couchpotato

whiptail --title "COUCHPOTATO" --msgbox "Installing upstart configurations" 8 78  
sleep 2
echo 'description "Upstart Script to run couchpotato as a service on Ubuntu/Debian based systems"' >> /etc/init/couchpotato.conf
echo "setuid "$UNAME >> /etc/init/couchpotato.conf
echo "setgid "$UNAME >> /etc/init/couchpotato.conf
echo 'start on runlevel [2345]' >> /etc/init/couchpotato.conf
echo 'stop on runlevel [016]' >> /etc/init/couchpotato.conf
echo 'respawn limit 10 10' >> /etc/init/couchpotato.conf
echo "exec  /home/"$UNAME"/.couchpotato/CouchPotato.py --config_file /home/xbmc/.couchpotato/settings.conf --data_dir /home/xbmc/.couchpotato/" >> /etc/init/couchpotato.conf

echo "[core]" > /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = "$API >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = "$USERNAME >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ssl_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ssl_cert = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "data_dir = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "permission_folder = 0755" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "development = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "url_base = /couchpotato" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "debug = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "launch_browser = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = "$PASSWORD >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "port = 5050" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "permission_file = 0755" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "show_wizard = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[download_providers]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[updater]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "notification = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "git_command = git" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automatic = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[automation]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "rating = 7.0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "votes = 1000" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "hour = 12" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "required_genres = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "year = 2011" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ignored_genres = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[manage]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "startup_scan = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "library_refresh_interval = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "cleanup = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "library = "$DIR"/Movies/" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[renamer]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "nfo_name = <filename>.orig.<ext>" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "from = "$DIR"/Downloads/Complete/Movies/" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "force_every = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "move_leftover = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "to = "$DIR"/Movies/" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "file_name = <thename><cd>.<ext>" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "next_on_failed = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "default_file_action = move" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "unrar = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "rename_nfo = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "cleanup = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "separator = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "folder_name = <namethe> (<year>)" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "run_every = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "foldersep = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "file_action = move" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ntfs_permission = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "unrar_path = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "unrar_modify_date = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "check_space = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[subtitle]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "languages = en" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "force = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[trailer]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "quality = 720p" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "name = <filename>-trailer" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[blackhole]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "directory = /home/xbmc" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "create_subdir = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "use_for = both" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[deluge]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_failed = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "completed_directory = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "label = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "paused = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = localhost:58846" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_files = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "directory = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "remove_complete = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[nzbget]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = admin" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "category = Movies" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_failed = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "priority = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ssl = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = localhost:6789" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = Raptor150" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[nzbvortex]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "group = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_failed = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = https://localhost:4321" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[pneumatic]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "directory = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[qbittorrent]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "paused = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = http://localhost:8080/" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_files = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "remove_complete = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[rtorrent]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "rpc_url = RPC2" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "label = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "paused = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ssl = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = localhost:80" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_files = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "directory = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "remove_complete = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[sabnzbd]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "category = Movies" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_failed = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "priority = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ssl = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = localhost:8085" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "remove_complete = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = "$API >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[synology]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "destination = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = localhost:5000" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "use_for = both" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[transmission]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = admin" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "stalled_as_failed = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_failed = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "rpc_url = transmission" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "paused = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = http://localhost:9091" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_files = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "directory = /data/Downloads/Complete/Movies/" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "remove_complete = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = Raptor150" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[utorrent]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_failed = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "manual = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "label = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "paused = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = localhost:8000" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "delete_files = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "remove_complete = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[notification_providers]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[boxcar2]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "token = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[email]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "starttls = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "smtp_pass = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "from = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "to = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "smtp_port = 25" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "smtp_server = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "smtp_user = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ssl = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[growl]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "hostname = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "port = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[nmj]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = localhost" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "mount = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "database = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[notifymyandroid]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "priority = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "dev_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[notifymywp]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "priority = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "dev_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[plex]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "clients = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "media_server = localhost" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[prowl]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "priority = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[pushalot]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "auth_token = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "important = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "silent = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[pushbullet]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "devices = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[pushover]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "sound = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "user_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "priority = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_token = YkxHMYDZp285L265L3IwH3LmzkTaCy" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[synoindex]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[toasty]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[trakt]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "remove_watchlist_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "notification_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_api_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[twitter]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "screen_name = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "access_token_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "mention = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "access_token_secret = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "direct_message = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[xbmc]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = "$USERNAME >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "force_full_scan = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "only_first = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "remote_dir_scan = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = localhost:8080" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = "$PASSWORD >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_disc_art_name = disc.png" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_extra_thumbs_name = extrathumbs/thumb<i>.jpg" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_thumbnail = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_extra_fanart = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_logo = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_enabled = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_landscape_name = landscape.jpg" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_nfo_name = %s.nfo" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_banner_name = banner.jpg" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_landscape = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_extra_fanart_name = extrafanart/extrafanart<i>.jpg" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_nfo = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_fanart = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_thumbnail_name = %s.tbn" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_url_only = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_fanart_name = %s-fanart.jpg" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_logo_name = logo.png" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_banner = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_clear_art = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_clear_art_name = clearart.png" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_extra_thumbs = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_disc_art = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[xmpp]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "on_snatch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "hostname = talk.google.com" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "to = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "port = 5222" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[nzb_providers]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[binsearch]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[newznab]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "use = 1,0,0,0,0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 10,0,0,0,0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = "$INDEXHOST"api.nzb.su,api.dognzb.cr,nzbs.org,https://api.nzbgeek.info" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "custom_tag = ,,,," >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = "$INDEXAPI",,,," >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[nzbclub]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[omgwtfnzbs]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 20" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[torrent_providers]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[awesomehd]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 20" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "only_internal = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "passkey = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "favor = both" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "prefer_internal = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[bithdtv]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 20" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[bitsoup]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 20" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[hdbits]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "passkey = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[ilovetorrents]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[iptorrents]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "freeleech = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[kickasstorrents]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "domain = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "only_verified = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[passthepopcorn]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "domain = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 20" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "passkey = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "prefer_scene = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "prefer_golden = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "require_approval = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "prefer_freeleech = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[sceneaccess]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 20" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[thepiratebay]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "domain = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = .5" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[torrentbytes]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 20" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[torrentday]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[torrentleech]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 20" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[torrentpotato]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "use = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "name = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "host = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "pass_key = ," >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[torrentshack]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "scene_only = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "password = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[torrentz]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "verified_only = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "minimal_seeds = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[yify]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_time = 40" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "domain = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "enabled = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "seed_ratio = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "extra_score = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[searcher]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "preferred_method = nzb" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "required_words = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "ignored_words = german, dutch, french, truefrench, danish, swedish, spanish, italian, korean, dubbed, swesub, korsub, dksubs, vain" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "preferred_words = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[nzb]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "retention = 1500" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[torrent]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "minimum_seeders = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[charts]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "hide_wanted = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "hide_library = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "max_items = 5" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[automation_providers]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[bluray]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "chart_display_enabled = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "backlog = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[flixster]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_ids_use = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_ids = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[goodfilms]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_username = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[imdb]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_charts_top250 = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "chart_display_boxoffice = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "chart_display_top250 = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "chart_display_rentals = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls_use = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_providers_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_charts_rentals = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "chart_display_theater = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_charts_theater = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "chart_display_enabled = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_charts_boxoffice = True" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[itunes]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls_use = ," >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls = https://itunes.apple.com/rss/topmovies/limit=25/xml," >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[kinepolis]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[letterboxd]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls_use = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[moviemeter]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[moviesio]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls_use = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls = " >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[popularmovies]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[rottentomatoes]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "tomatometer_percent = 80" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls_use = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "automation_urls = http://www.rottentomatoes.com/syndication/rss/in_theaters.xml" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[themoviedb]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "api_key = 9b939aee0aaafc12a65bf448e4af9543" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[mediabrowser]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[sonyps3]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[windowsmediacenter]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "meta_enabled = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "[moviesearcher]" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "cron_day = *" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "cron_hour = */6" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "cron_minute = 53" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "always_search = False" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "run_on_launch = 0" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "search_on_add = 1" >> /home/xbmc/IPVR/.couchpotato/settings.conf 
echo "" >> /home/xbmc/IPVR/.couchpotato/settings.conf 

whiptail --msgbox "All done.  couchpotato should start within 10-20 seconds If not you can start it using (sudo start couchpotato) command.  Then open http://localhost:5050 in your browser. Replace localhost with your server IP for remote systems.  ***If this script worked for you, please visit http://www.htpcBeginner.com and like/follow us." 12 78 --title "FINISHED"

sudo start couchpotato
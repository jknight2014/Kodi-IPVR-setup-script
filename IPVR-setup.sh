#!/bin/bash
# Script Name: Knight IPVR installer
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
export NCURSES_NO_UTF8_ACS=1
sudo echo 'Dpkg::Progress-Fancy "1";' > /etc/apt/apt.conf.d/99progressbar
if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you must run this script as root. Add sudo to the beginning of your start command(sudo bash SCRIPT)"
	exit 1
fi
echo "starting installer"
sudo apt-get -qq install dialog >/dev/null 2>&1

if (dialog --title "Knight IPVR" --yesno "Version: 0.1 (November 16, 2014) Knight IPVR installation will start soon. Please read the following carefully. The script has been confirmed to work on Ubuntu 14.04. 2. While several testing runs identified no known issues, the author cannot be held accountable for any problems that might occur due to the script. 3. If you did not run this script with sudo, you maybe asked for your root password during installation." 12 78) then
    echo
else
    dialog --title "ABORT" --infobox "You have aborted. Please try again." 6 50
	exit 0
fi

UNAME=$(dialog --title "System Username" --inputbox "Enter the user you want your scripts to run as. (Case sensitive, Must exist)" 10 50 3>&1 1>&2 2>&3)

if [ ! -d "/home/$UNAME" ]; then
  dialog --msgbox 'Your username was not found. Your user must have a home folder in the "/home" directory' 10 30
  exit 0
fi

USERNAME=$(dialog --title "Username" --inputbox "Enter the username you want to use to log into your scripts" 10 50 3>&1 1>&2 2>&3)
PASSWORD=$(dialog --title "Password" --passwordbox "Enter the Password you want to use to log into your scripts" 10 50 3>&1 1>&2 2>&3)
DIR=$(dialog --title "Storage Directory" --inputbox "Enter the directory where you would like downloads saved. (/home/john would save complete downloads in /home/john/Downloads/Complete" 10 50 /home/$UNAME 3>&1 1>&2 2>&3)
DIR=${DIR%/}
API=$(date +%s | sha256sum | base64 | head -c 32 ; sudo echo)
USENETHOST=$(dialog --title "Usenet" --inputbox "Please enter your Usenet servers Hostname" 10 50 3>&1 1>&2 2>&3)
USENETUSR=$(dialog --title "Usenet" --inputbox "Please enter your Usenet servers Username" 10 50 3>&1 1>&2 2>&3)
USENETPASS=$(dialog --title "Usenet" --inputbox "Please enter your Usenet servers Password" 10 50 3>&1 1>&2 2>&3)
USENETPORT=$(dialog --title "Usenet" --inputbox "Please enter your Usenet servers connection Port" 10 50 3>&1 1>&2 2>&3)
USENETCONN=$(dialog --title "Usenet" --inputbox "Please enter the maximum number of connections your server allowes " 10 50 3>&1 1>&2 2>&3)
if (dialog --title "Usenet" --yesno "Does your usenet server use SSL?" 8 50) then
    USENETSSL=1
else
    USENETSSL=0
fi

INDEXERHOST=$(dialog --title "Usenet Indexer" --inputbox "Please enter your Newsnab powered Indexers hostname" 10 50 3>&1 1>&2 2>&3)
INDEXERAPI=$(dialog --title "Usenet Indexer" --inputbox "Please enter your Newsnab powered Indexers API key" 10 50 3>&1 1>&2 2>&3)
INDEXERNAME=$(dialog --title "Usenet Indexer" --inputbox "Please enter a name for your Newsnab powered Indexer (This can be anything)" 10 50 3>&1 1>&2 2>&3)

APPS=$(dialog --checklist "Choose which apps you would like installed:" 20 50 3 \
"SABnzbd" "" on \
"Sonarr" "" on \
"CouchPotato" "" on 3>&1 1>&2 2>&3)

if [[ $APPS == *CouchPotato* ]]
then
CP=1
fi

if [[ $APPS == *SABnzbd* ]]
then
SAB=1
fi

if [[ $APPS == *Sonarr* ]]
then
SONARR=1
fi


dialog --title "Knight IPVR" --infobox "Setting things up" 6 50

sudo mkdir $DIR/Movies
sudo mkdir $DIR/TVShows
sudo mkdir $DIR/Downloads
sudo mkdir $DIR/Downloads/Complete
sudo mkdir $DIR/Downloads/Incomplete
sudo mkdir $DIR/Downloads/Complete/Movies
sudo mkdir $DIR/Downloads/Complete/TV
sudo chown -R $UNAME:$UNAME $DIR/Movies
sudo chown -R $UNAME:$UNAME $DIR/TVShows
sudo chown -R $UNAME:$UNAME $DIR/Downloads
sudo chmod -R 775 $DIR/Movies
sudo chmod -R 775 $DIR/TVShows
sudo chmod -R 775 $DIR/Downloads
sudo mkdir /home/$UNAME/IPVR
sudo mkdir /home/$UNAME/IPVR/.sabnzbd
sudo chown -R $UNAME:$UNAME /home/$UNAME/IPVR
sudo chmod -R 775 /home/$UNAME/IPVR
	dialog --title "Knight IPVR" --infobox "Adding repositories" 6 50
	sudo add-apt-repository -y ppa:jcfp/ppa >/dev/null 2>&1
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC >/dev/null 2>&1
	sudo echo "deb http://update.nzbdrone.com/repos/apt/debian master main" | sudo tee -a /etc/apt/sources.list >/dev/null 2>&1

	dialog --title "Knight IPVR" --infobox "Updating Packages" 6 50
	sudo apt-get -qq update >/dev/null 2>&1
if [[ "$SAB" == "1" ]] 
then

	dialog --title "SABnzbd" --infobox "Installing SABnzbd" 6 50
	sudo apt-get -qq install sabnzbdplus >/dev/null 2>&1

	dialog --title "SABnzbd" --infobox "Stopping SABnzbd" 6 50
	sleep 2
	sudo killall sabnzbd* >/dev/null 2>&1

	dialog --title "SABnzbd" --infobox "Removing Standard init scripts" 6 50
	sudo update-rc.d -f sabnzbdplus remove  >/dev/null 2>&1

	dialog --title "SABnzbd" --infobox "Adding SABnzbd upstart config" 6 50
	sleep 2
	sudo echo 'description "Upstart Script to run sabnzbd as a service on Ubuntu/Debian based systems"' > /etc/init/sabnzbd.conf
	sudo echo "setuid "$UNAME >> /etc/init/sabnzbd.conf
	sudo echo "setgid "$UNAME >> /etc/init/sabnzbd.conf
	sudo echo 'start on runlevel [2345]' >> /etc/init/sabnzbd.conf
	sudo echo 'stop on runlevel [016]' >> /etc/init/sabnzbd.conf
	sudo echo 'respawn limit 10 10' >> /etc/init/sabnzbd.conf
	sudo echo "exec sabnzbdplus -f /home/"$UNAME"/IPVR/.sabnzbd/config.ini -s 0.0.0.0:8085" >> /etc/init/sabnzbd.conf

	sudo start sabnzbd >/dev/null 2>&1
	sleep 5
	sudo stop sabnzbd >/dev/null 2>&1
	
	dialog --title "SABnzbd" --infobox "Configuring SABnzbd" 6 50
	sudo echo "username = "$USERNAME > /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "api_key = "$API >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "complete_dir = "$DIR"/Downloads/Complete" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "download_dir = "$DIR"/Downloads/Incomplete" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "[servers]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "[["$USENETHOST"]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "username = "$USENETUSR >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "enable = 1" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "name = "$USENETHOST >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "fillserver = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "connections = "$USENETCONN >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "ssl = "$USENETSSL >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "host = "$USENETHOST >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "timeout = 120" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "password = "$USENETPASS >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "optional = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "port = "$USENETPORT >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "retention = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "[categories]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "[[*]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "priority = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "pp = 3" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "name = *" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "script = None" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo 'newzbin = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo 'dir = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "[[tv]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "priority = -100" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo 'pp = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "name = TV" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "script = Default" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo 'newzbin = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "dir = "$DIR"/Downloads/Complete/TVShows" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "[[movies]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "priority = -100" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo 'pp = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "name = Movies" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "script = Default" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo 'newzbin = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	sudo echo "dir = "$DIR"/Downloads/Complete/Movies" >> /home/$UNAME/IPVR/.sabnzbd/config.ini

	dialog --infobox "SABnzbd has finished installing. Continuing with Sonarr install." 6 50
fi

if [[ "$SONARR" == "1" ]] 
then

	dialog --title "SONARR" --infobox "Installing mono \ This may take awhile. Please be paient." 6 50
	sudo apt-get -qq install mono-complete  >/dev/null 2>&1

	dialog --title "SONARR" --infobox "Checking for previous versions of NZBget/Sonarr..." 6 50
	sleep 2
	sudo killall sonarr* >/dev/null 2>&1
	sudo killall nzbget* >/dev/null 2>&1

	dialog --title "SONARR" --infobox "Downloading latest Sonarr..." 6 50
	sleep 2
	sudo apt-get -qq install nzbdrone >/dev/null 2>&1
	
	dialog --title "SONARR" --infobox "Creating new default and init scripts..." 6 50
	sleep 2
	sudo echo 'description "Upstart Script to run sonarr as a service on Ubuntu/Debian based systems"' > /etc/init/sonarr.conf
	sudo echo "setuid "$UNAME >> /etc/init/sonarr.conf
	sudo echo 'env DIR=/opt/NzbDrone' >> /etc/init/sonarr.conf
	sudo echo 'setgid nogroup' >> /etc/init/sonarr.conf
	sudo echo 'start on runlevel [2345]' >> /etc/init/sonarr.conf
	sudo echo 'stop on runlevel [016]' >> /etc/init/sonarr.conf
	sudo echo 'respawn limit 10 10' >> /etc/init/sonarr.conf
	sudo echo 'exec mono $DIR/NzbDrone.exe' >> /etc/init/sonarr.conf
	 
	sudo start sonarr >/dev/null 2>&1
	
	while [ ! -f /home/$UNAME/.config/NzbDrone/config.xml ]
do
  sleep 2
done

	while [ ! -f /home/$UNAME/.config/NzbDrone/nzbdrone.db ]
do
  sleep 2
done
	sudo stop sonarr >/dev/null 2>&1

	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = '"$UNAME"' WHERE Key = 'chownuser'"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = '"$UNAME"' WHERE Key = 'chowngroup'"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = '"$DIR"/Downloads/Complete/TV' WHERE Key = 'downloadedepisodesfolder'"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "INSERT INTO DownloadClients VALUES (NULL,'1','Sabnzbd,'Sabnzbd','{"host": "localhost", "port": 8085, "apiKey": "$API", "username": "$USERNAME", "password": "$PASSWORD", "tvCategory": "tv", "recentTvPriority": 1, "olderTvPriority": -100, "useSsl": false}', 'SabnzbdSettings')"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "INSERT INTO Indexers VALUES (NULL,'"$INDEXNAME"','Newznab,'{ "url": "$INDEXHOST", "apiKey": "$INDEXAPI", "categories": [   5030,   5040 ], "animeCategories": []  }','NewznabSettings','1','1')"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "INSERT INTO RootFolders VALUES (NULL,'"$DIR"/TVShows')"

	sudo echo '<?xml version="1.0" encoding="utf-8" standalone="yes"?>' > /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "<Config>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <Port>8989</Port>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <SslPort>9898</SslPort>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <EnableSsl>False</EnableSsl>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <LaunchBrowser>False</LaunchBrowser>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <ApiKey>32cc1aa3d523445c8612bd5d130ba74a</ApiKey>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <AuthenticationEnabled>True</AuthenticationEnabled>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <Branch>torrents</Branch>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <Username>"$USERNAME"</Username>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <Password>"$PASSWORD"</Password>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <LogLevel>Trace</LogLevel>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <SslCertHash>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  </SslCertHash>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <UrlBase>sonarr</UrlBase>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <UpdateMechanism>BuiltIn</UpdateMechanism>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "  <UpdateAutomatically>True</UpdateAutomatically>" >> /home/$UNAME/.config/NzbDrone/config.xml 
	sudo echo "</Config>" >> /home/$UNAME/.config/NzbDrone/config.xml 

	dialog --title "FINISHED" --infobox "Sonarr has finished installing. Continuing with CouchPotato install." 6 50
fi
if [[ "$CP" == "1" ]] 
then

	dialog --title "COUCHPOTATO" --infobox "Installing Git and Python" 6 50  
	sudo apt-get -qq install git-core python >/dev/null 2>&1


	dialog --title "COUCHPOTATO" --infobox "Killing and version of couchpotato currently running" 6 50  
	sleep 2
	sudo killall couchpotato* >/dev/null 2>&1


	dialog --title "COUCHPOTATO" --infobox "Downloading the latest version of CouchPotato" 6 50  
	sleep 2
	git clone git://github.com/RuudBurger/CouchPotatoServer.git /home/$UNAME/IPVR/.couchpotato >/dev/null 2>&1

	dialog --title "COUCHPOTATO" --infobox "Installing upstart configurations" 6 50  
	sleep 2
	sudo echo 'description "Upstart Script to run couchpotato as a service on Ubuntu/Debian based systems"' > /etc/init/couchpotato.conf
	sudo echo "setuid "$UNAME >> /etc/init/couchpotato.conf
	sudo echo "setgid "$UNAME >> /etc/init/couchpotato.conf
	sudo echo 'start on runlevel [2345]' >> /etc/init/couchpotato.conf
	sudo echo 'stop on runlevel [016]' >> /etc/init/couchpotato.conf
	sudo echo 'respawn limit 10 10' >> /etc/init/couchpotato.conf
	sudo echo "exec  /home/"$UNAME"/IPVR/.couchpotato/CouchPotato.py --config_file /home/"$UNAME"/IPVR/.couchpotato/settings.conf --data_dir /home/"$UNAME"/IPVR/.couchpotato/" >> /etc/init/couchpotato.conf

	sudo echo "[core]" > /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = "$API >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = "$USERNAME >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ssl_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ssl_cert = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "data_dir = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "permission_folder = 0755" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "development = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "url_base = /couchpotato" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "debug = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "launch_browser = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "port = 5050" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "permission_file = 0755" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "show_wizard = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[download_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[updater]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "notification = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "git_command = git" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automatic = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[automation]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "rating = 7.0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "votes = 1000" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "hour = 12" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "required_genres = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "year = 2011" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ignored_genres = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[manage]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "startup_scan = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "library_refresh_interval = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "cleanup = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "library = "$DIR"/Movies/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[renamer]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "nfo_name = <filename>.orig.<ext>" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "from = "$DIR"/Downloads/Complete/Movies/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "force_every = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "move_leftover = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "to = "$DIR"/Movies/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "file_name = <thename><cd>.<ext>" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "next_on_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "default_file_action = move" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "unrar = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "rename_nfo = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "cleanup = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "separator = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "folder_name = <namethe> (<year>)" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "run_every = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "foldersep = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "file_action = move" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ntfs_permission = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "unrar_path = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "unrar_modify_date = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "check_space = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[subtitle]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "languages = en" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "force = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[trailer]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "quality = 720p" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "name = <filename>-trailer" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[blackhole]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "directory = /home/$UNAME" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "create_subdir = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "use_for = both" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[deluge]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "completed_directory = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "label = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = localhost:58846" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "directory = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "remove_complete = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[nzbget]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = admin" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "category = Movies" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ssl = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = localhost:6789" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[nzbvortex]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "group = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = https://localhost:4321" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[pneumatic]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "directory = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[qbittorrent]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = http://localhost:8080/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "remove_complete = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[rtorrent]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "rpc_url = RPC2" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "label = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ssl = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = localhost:80" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "directory = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "remove_complete = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[sabnzbd]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "category = Movies" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ssl = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = localhost:8085" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "remove_complete = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = "$API >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[synology]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "destination = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = localhost:5000" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "use_for = both" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[transmission]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = admin" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "stalled_as_failed = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "rpc_url = transmission" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = http://localhost:9091" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "directory = /data/Downloads/Complete/Movies/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "remove_complete = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[utorrent]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "label = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = localhost:8000" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "remove_complete = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[notification_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[boxcar2]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "token = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[email]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "starttls = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "smtp_pass = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "from = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "to = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "smtp_port = 25" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "smtp_server = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "smtp_user = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ssl = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[growl]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "hostname = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "port = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[nmj]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = localhost" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "mount = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "database = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[notifymyandroid]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "dev_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[notifymywp]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "dev_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[plex]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "clients = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "media_server = localhost" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[prowl]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[pushalot]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "auth_token = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "important = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "silent = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[pushbullet]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "devices = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[pushover]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "sound = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "user_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_token = YkxHMYDZp285L265L3IwH3LmzkTaCy" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[synoindex]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[toasty]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[trakt]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "remove_watchlist_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "notification_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[twitter]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "screen_name = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "access_token_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "mention = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "access_token_secret = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "direct_message = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[$UNAME]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = "$USERNAME >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "force_full_scan = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "only_first = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "remote_dir_scan = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = localhost:8080" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_disc_art_name = disc.png" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_extra_thumbs_name = extrathumbs/thumb<i>.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_thumbnail = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_extra_fanart = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_logo = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_landscape_name = landscape.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_nfo_name = %s.nfo" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_banner_name = banner.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_landscape = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_extra_fanart_name = extrafanart/extrafanart<i>.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_nfo = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_fanart = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_thumbnail_name = %s.tbn" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_url_only = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_fanart_name = %s-fanart.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_logo_name = logo.png" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_banner = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_clear_art = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_clear_art_name = clearart.png" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_extra_thumbs = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_disc_art = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[xmpp]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "hostname = talk.google.com" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "to = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "port = 5222" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[nzb_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[binsearch]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[newznab]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "use = 1,0,0,0,0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 10,0,0,0,0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = "$INDEXHOST"api.nzb.su,api.dognzb.cr,nzbs.org,https://api.nzbgeek.info" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "custom_tag = ,,,," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = "$INDEXAPI",,,," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[nzbclub]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[omgwtfnzbs]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[torrent_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[awesomehd]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "only_internal = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "passkey = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "favor = both" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "prefer_internal = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[bithdtv]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[bitsoup]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[hdbits]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "passkey = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[ilovetorrents]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[iptorrents]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "freeleech = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[kickasstorrents]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "domain = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "only_verified = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[passthepopcorn]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "domain = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "passkey = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "prefer_scene = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "prefer_golden = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "require_approval = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "prefer_freeleech = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[sceneaccess]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[thepiratebay]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "domain = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = .5" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[torrentbytes]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[torrentday]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[torrentleech]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[torrentpotato]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "name = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "host = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "pass_key = ," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[torrentshack]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "scene_only = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[torrentz]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "verified_only = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "minimal_seeds = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[yify]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "domain = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[searcher]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "preferred_method = nzb" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "required_words = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "ignored_words = german, dutch, french, truefrench, danish, swedish, spanish, italian, korean, dubbed, swesub, korsub, dksubs, vain" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "preferred_words = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[nzb]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "retention = 1500" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[torrent]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "minimum_seeders = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[charts]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "hide_wanted = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "hide_library = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "max_items = 5" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[automation_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[bluray]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "chart_display_enabled = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "backlog = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[flixster]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_ids_use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_ids = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[goodfilms]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[imdb]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_charts_top250 = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "chart_display_boxoffice = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "chart_display_top250 = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "chart_display_rentals = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls_use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_providers_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_charts_rentals = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "chart_display_theater = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_charts_theater = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "chart_display_enabled = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_charts_boxoffice = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[itunes]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls_use = ," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls = https://itunes.apple.com/rss/topmovies/limit=25/xml," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[kinepolis]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[letterboxd]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls_use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[moviemeter]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[moviesio]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls_use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[popularmovies]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[rottentomatoes]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "tomatometer_percent = 80" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls_use = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "automation_urls = http://www.rottentomatoes.com/syndication/rss/in_theaters.xml" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[themoviedb]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "api_key = 9b939aee0aaafc12a65bf448e4af9543" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[mediabrowser]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[sonyps3]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[windowsmediacenter]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "meta_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "[moviesearcher]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "cron_day = *" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "cron_hour = */6" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "cron_minute = 53" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "always_search = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "run_on_launch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "search_on_add = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	sudo echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	
fi

dialog --title "Permissions" --infobox "Fixing Ownership and Permissions." 5 50
sudo chmod -R 775 /home/$UNAME/IPVR/
sudo chown -R $UNAME:$UNAME /home/$UNAME/IPVR/

dialog --title "FINISHED" --msgbox "All done.  Your IPVR should start within 10-20 seconds If not you can start it using (sudo start sabnzbd sonarr couchpotato) command.  Then open http://localhost:#PORT in your browser. Replace #PORT with the port of the program you want to access. Couchpotato = 5050 Sonarr = 8989 SABnzbd = 8085. Replace localhost with your server IP for remote systems." 15 78


sudo start sabnzbd
sudo start sonarr
sudo start couchpotato

if (dialog --title "Knight IPVR" --yesno "Would you like to enable reverse proxies? \ This will allow you to access your programs at http://hostname/script instead of http://IP:PORT/script. It will also allow you to use SSL and access your apps from outside your network by only forwarding one port." 12 78) then
    echo
else
    dialog --title "ABORT" --infobox "All Done then!" 6 50
	exit 0
fi

dialog --title "Apache" --infobox "Installing Apache" 6 50
sudo apt-get -qq install apache2 > /dev/null 2>&1

sudo a2enmod proxy > /dev/null 2>&1
sudo a2enmod proxy_http > /dev/null 2>&1
sudo a2enmod rewrite > /dev/null 2>&1
sudo a2enmod ssl > /dev/null 2>&1
sudo openssl req -x509 -nodes -days 7200 -newkey rsa:2048 -subj "/C=US/ST=NONE/L=NONE/O=Private/CN=Private" -keyout /etc/ssl/private/apache.key -out /etc/ssl/certs/apache.crt
echo "" > /etc/apache2/sites-available/000-default.conf
echo "<VirtualHost *:80>" > /etc/apache2/sites-available/000-default.conf 
echo "RewriteEngine on" >> /etc/apache2/sites-available/000-default.conf 
echo "ReWriteCond %{SERVER_PORT} !^443$" >> /etc/apache2/sites-available/000-default.conf 
echo "RewriteRule ^/(.*) https://%{HTTP_HOST}/$1 [NC,R,L]" >> /etc/apache2/sites-available/000-default.conf 
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "<VirtualHost *:443>" >> /etc/apache2/sites-available/000-default.conf 
echo "ServerAdmin admin@domain.com" >> /etc/apache2/sites-available/000-default.conf 
echo "ServerName localhost" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyRequests Off" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPreserveHost On" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "<Proxy *>" >> /etc/apache2/sites-available/000-default.conf 
echo "Order deny,allow" >> /etc/apache2/sites-available/000-default.conf 
echo "Allow from all" >> /etc/apache2/sites-available/000-default.conf 
echo "</Proxy>" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "<Location />" >> /etc/apache2/sites-available/000-default.conf 
echo "Order allow,deny" >> /etc/apache2/sites-available/000-default.conf 
echo "Allow from all" >> /etc/apache2/sites-available/000-default.conf 
echo "</Location>" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "SSLEngine On" >> /etc/apache2/sites-available/000-default.conf 
echo "SSLProxyEngine On" >> /etc/apache2/sites-available/000-default.conf 
echo "SSLCertificateFile /etc/ssl/certs/apache.crt" >> /etc/apache2/sites-available/000-default.conf 
echo "SSLCertificateKeyFile /etc/ssl/private/apache.key" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPass /sabnzbd http://localhost:8085/sabnzbd" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPassReverse /sabnzbd http://localhost:8085/sabnzbd" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPass /sonarr http://localhost:8989/sonarr" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPassReverse /sonarr http://localhost:8989/sonarr" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPass /couchpotato http://localhost:5050/couchpotato" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPassReverse /couchpotato http://localhost:5050/couchpotato" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "RewriteEngine on" >> /etc/apache2/sites-available/000-default.conf 
echo "RewriteRule ^/xbmc$ /xbmc/ [R]" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPass /xbmc http://localhost:8080" >> /etc/apache2/sites-available/000-default.conf 
echo "ProxyPassReverse /xbmc http://localhost:8080" >> /etc/apache2/sites-available/000-default.conf 
echo "" >> /etc/apache2/sites-available/000-default.conf 
echo "ErrorLog /var/log/apache2/error.log" >> /etc/apache2/sites-available/000-default.conf 
echo "LogLevel warn" >> /etc/apache2/sites-available/000-default.conf 
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf
sudo service apache2 restart 
fi
dialog --title "FINISHED" --msgbox "Apache rewrite installed. Use https://HOST/sonarr to access sonarr, same for couchpotato and sabnzbd" 5 50
#!/bin/bash

# Define colors
red='\e[0;31m'
green='\e[1;32m'
blue='\e[1;36m'
NC='\e[0m' # No color

clear


# Determine Ubuntu Version Codename
VERSION=$(lsb_release -cs)

# Check if stages.cfg exists. If not, created it. 
if [ ! -f stages.cfg ]
then
echo 'updates_installed=0
grub_recovery_disable=0
wireless_enabled=0
xorg_installed=0
admin_created=0
kiosk_created=0
kiosk_autologin=0
screensaver_installed=0
chromium_installed=0
kiosk_scripts=0
mplayer_installed=0
ajenti_installed=0
ajenti_plugins_installed=0
nginx_installed=0
php_installed=0
website_downloaded=0
touchscreen_installed=0
audio_installed=0
additional_software_installed=0
crontab_installed=0
plymouth_theme_installed=0
prevent_sleeping=0
kiosk_permissions=0' > stages.cfg
fi

# Import stages config
. stages.cfg


# Prevent sleeping for inactivity
echo -e "${red}Prevent sleeping for inactivity...${NC}\n"
if [ "$prevent_sleeping" == 0 ]
then
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/kbd/config -O /etc/kbd/config
sed -i -e 's/prevent_sleeping=0/prevent_sleeping=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Prevent sleeping already done. Skipping...${NC}\n"
fi

# Refresh
apt-get update

# Clean
apt-get autoremove
apt-get clean
sed -i -e 's/updates_installed=0/updates_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"



echo -e "${red}Disabling root recovery mode...${NC}\n"
if [ "$grub_recovery_disable" == 0 ]
then
sed -i -e 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/g' /etc/default/grub
sed -i -e 's/GRUB_DISTRIBUTOR=`lsb_release -i -s 2> \/dev\/null || echo Debian`/GRUB_DISTRIBUTOR=Kiosk/g' /etc/default/grub
sed -i -e 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=4/g' /etc/default/grub
update-grub
sed -i -e 's/grub_recovery_disable=0/grub_recovery_disable=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Root recovery already disabled. Skipping...${NC}\n"
fi


echo -e "${red}Installing a graphical user interface...${NC}\n"
if [ "$xorg_installed" == 0 ]
then
apt-get -y  install --no-install-recommends xorg nodm matchbox-window-manager 

# Hide Cursor
apt-get -y  install --no-install-recommends unclutter 
sed -i -e 's/xorg_installed=0/xorg_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Xorg already installed. Skipping...${NC}\n"
fi


echo -e "${red}Creating administrator user...${NC}\n"
if [ "$admin_created" == 0 ]
then
useradd administrator -m -d /home/administrator -p `openssl passwd -crypt ISdjE830` -s /bin/bash
sed -i -e 's/admin_created=0/admin_created=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Administrator already created. Skipping...${NC}\n"
fi


echo -e "${red}Creating kiosk user...${NC}\n"
if [ "$kiosk_created" == 0 ]
then
useradd kiosk -m -d /home/kiosk -p 'K10sk201' -s /bin/bash
sed -i -e 's/kiosk_created=0/kiosk_created=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk already created. Skipping...${NC}\n"
fi


# Configure kiosk autologin
echo -e "${red}Configuring kiosk autologin...${NC}\n"
if [ "$kiosk_autologin" == 0 ]
then
sed -i -e 's/NODM_ENABLED=false/NODM_ENABLED=true/g' /etc/default/nodm
sed -i -e 's/NODM_USER=root/NODM_USER=kiosk/g' /etc/default/nodm
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/init.d/nodm -O /etc/init.d/nodm
sed -i -e 's/kiosk_autologin=0/kiosk_autologin=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk autologin already configured. Skipping...${NC}\n"
fi


# Create .xscreensaver
echo -e "${red}Installing and configuring the screensaver...${NC}\n"
if [ "$screensaver_installed" == 0 ]
then
apt-get -y  install --no-install-recommends xscreensaver xscreensaver-data-extra xscreensaver-gl-extra libwww-perl 
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/xscreensaver -O /home/kiosk/.xscreensaver

# Create the screensaver directory
mkdir /home/kiosk/screensavers
sed -i -e 's/screensaver_installed=0/screensaver_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Screensaver already configured. Skipping...${NC}\n"
fi


# Install Chromium browser
echo -e "${red}Installing ${blue}Chromium${red} browser...${NC}\n"
if [ "$chromium_installed" == 0 ]
then
echo "
# Ubuntu Partners
deb http://archive.canonical.com/ $VERSION partner
"  >> /etc/apt/sources.list
apt-get  update
apt-get -y  install --force-yes chromium-browser 
apt-get -y  install flashplugin-installer icedtea-7-plugin ttf-liberation  # flash, java, and fonts
sed -i -e 's/chromium_installed=0/chromium_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Chromium already installed. Skipping...${NC}\n"
fi


# Kiosk scripts
echo -e "${red}Creating Kiosk Scripts...${NC}\n"
if [ "$kiosk_scripts" == 0 ]
then
mkdir /home/kiosk/.kiosk

# Create xsession
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/xsession -O /home/kiosk/.xsession

# Create other kiosk scripts
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/browser.cfg -O /home/kiosk/.kiosk/browser.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/browser_killer.sh -O /home/kiosk/.kiosk/browser_killer.sh
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/browser_switches.cfg -O /home/kiosk/.kiosk/browser_switches.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/glslideshow_switches.cfg -O /home/kiosk/.kiosk/glslideshow_switches.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/screensaver.cfg -O /home/kiosk/.kiosk/screensaver.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/set_glslideshow_switches.sh -O /home/kiosk/.kiosk/set_glslideshow_switches.sh
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/videos.cfg -O /home/kiosk/.kiosk/videos.cfg
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/kiosk/videos_switches.cfg -O /home/kiosk/.kiosk/videos_switches.cfg

# Create browser killer
apt-get -y  install --no-install-recommends xprintidle 
chmod +x /home/kiosk/.kiosk/browser_killer.sh
sed -i -e 's/kiosk_scripts=0/kiosk_scripts=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk scripts already installed. Skipping...${NC}\n"
fi


# Mplayer
echo -e "${red}Installing video player ${blue}mplayer${red}...${NC}\n"
if [ "$mplayer_installed" == 0 ]
then
apt-get -y  install mplayer 
mkdir /home/kiosk/videos
sed -i -e 's/mplayer_installed=0/mplayer_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Mplayer already installed. Skipping...${NC}\n"
fi


# Kiosk Web Control (Ajenti)
echo -e "${red}Adding the browser-based system administration tool ${blue}Kiosk web control${red}...${NC}\n"
if [ "$ajenti_installed" == 0 ]
then
add-apt-repository universe
apt-get install build-essential python3-pip python3-dev python3-lxml libssl-dev python3-dbus python3-augeas python3-apt ntpdate
sudo pip3 install ajenti-panel ajenti.plugin.ace ajenti.plugin.augeas ajenti.plugin.auth-users ajenti.plugin.core ajenti.plugin.dashboard ajenti.plugin.datetime ajenti.plugin.filemanager ajenti.plugin.filesystem ajenti.plugin.network ajenti.plugin.notepad ajenti.plugin.packages ajenti.plugin.passwd ajenti.plugin.plugins ajenti.plugin.power ajenti.plugin.services ajenti.plugin.settings ajenti.plugin.terminal
service ajenti stop
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/ajenti/config.json -O /etc/ajenti/config.json

wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/dashboard/content/js/controls.dashboard.coffee.c.js
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml -O /usr/share/pyshared/ajenti/plugins/dashboard/layout/dash.xml
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/fm/__init__.py -O /usr/share/pyshared/ajenti/plugins/fm/__init__.py
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/fm/fm.py -O /usr/share/pyshared/ajenti/plugins/fm/fm.py
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/fm/layout/main.xml -O /usr/share/pyshared/ajenti/plugins/fm/layout/main.xml
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js -O /usr/share/pyshared/ajenti/plugins/main/content/js/controls.index.coffee.c.js
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/main/content/static/auth.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/auth.html
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/main/content/static/index.html -O /usr/share/pyshared/ajenti/plugins/main/content/static/index.html
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/pyshared/ajenti/plugins/power/layout/widget.xml -O /usr/share/pyshared/ajenti/plugins/power/layout/widget.xml
sed -i -e 's/ajenti_installed=0/ajenti_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk web control already installed. Skipping...${NC}\n"
fi



echo -e "${red}Adding Kiosk plugins to Kiosk web control...${NC}\n"
if [ "$ajenti_plugins_installed" == 0 ]
then
apt-get -y  install --no-install-recommends unzip 
wget -q https://github.com/mmihalev/Ajenti-Plugins/archive/master.zip -O kiosk_plugins-master.zip
unzip -qq kiosk_plugins-master.zip
mv Ajenti-Plugins-master/* /var/lib/ajenti/plugins/
rm -rf Ajenti-Plugins-master
rm -rf /var/lib/ajenti/plugins/sanickiosk_*
sed -i -e 's/ajenti_plugins_installed=0/ajenti_plugins_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Kiosk plugins already installed. Skipping...${NC}\n"
fi


#NGINX
echo -e "${red}Installing ${blue}nginx${red} web server...${NC}\n"
if [ "$nginx_installed" == 0 ]
then
apt-get -y  install nginx 
service nginx stop
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/nginx/sites-enabled/default -O /etc/nginx/sites-available/default
sed -i -e 's/www-data/kiosk/g' /etc/nginx/nginx.conf
mkdir /home/kiosk/html
chown -R kiosk.kiosk /home/kiosk/html
service nginx start
sed -i -e 's/nginx_installed=0/nginx_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Nginx already installed. Skipping...${NC}\n"
fi

#PHP
echo -e "${red}Installing ${blue}PHP${red}...${NC}\n"
if [ "$php_installed" == 0 ]
then
apt-get -y  install php5-cli php5-common php5-fpm php5-mysqlnd php5-mcrypt
update-rc.d php5-fpm defaults
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/php5/fpm/php.ini -O /etc/php5/fpm/php.ini
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/php5/fpm/pool.d/www.conf -O /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
sed -i -e 's/php_installed=0/php_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}PHP already installed. Skipping...${NC}\n"
fi



# Website content
echo -e "${red}Downloading ${blue}Website content${red}...${NC}\n"
if [ "$website_downloaded" == 0 ]
then
wget -q https://dl.dropboxusercontent.com/u/47604729/kiosk_html.zip -O kiosk_html.zip
unzip -qq kiosk_html.zip
mv kiosk_html/* /home/kiosk/html/
chown -R kiosk.kiosk /home/kiosk/html/*
rm -rf kiosk_html*	
service nginx restart
service php5-fpm restart
sed -i -e 's/website_downloaded=0/website_downloaded=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Website content already downloaded. Skipping...${NC}\n"
fi	


	
echo -e "${red}Installing touchscreen support...${NC}\n"
if [ "$touchscreen_installed" == 0 ]
then
apt-get -y  install --no-install-recommends xserver-xorg-input-multitouch xinput-calibrator 
sed -i -e 's/touchscreen_installed=0/touchscreen_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Touchscreen support already installed. Skipping...${NC}\n"
fi

echo -e "${red}Installing audio...${NC}\n"
if [ "$audio_installed" == 0 ]
then
apt-get -y  install --no-install-recommends alsa 
adduser kiosk audio
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/home/kiosk/asoundrc -O /home/kiosk/.asoundrc
chown kiosk.kiosk /home/kiosk/.asoundrc
sed -i -e 's/audio_installed=0/audio_installed=1/g' stages.cfg
echo -e "\n${green}Done!${NC}\n"
else
	echo -e "${blue}Audio already installed. Skipping...${NC}\n"
fi


echo -e "${red}Installing 3rd party software...${NC}\n"
if [ "$additional_software_installed" == 0 ]
then
apt-get -y  install pulseaudio 
apt-get -y  install libvdpau* 
apt-get -y  install alsa-utils 
apt-get -y  install mc 

wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/etc/pulse/default.pa -O /etc/pulse/default.pa
sed -i -e 's/additional_software_installed=0/additional_software_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}3rd party software already installed. Skipping...${NC}\n"
fi



# Crontab for fixing hdmi sound mute problem
if [ "$crontab_installed" == 0 ]
then
echo -e "${red}Crontab for fixing hdmi sound mute problem${NC}\n"
echo "* * * * * /usr/bin/amixer set IEC958 unmute" > cron
crontab -l -u kiosk | cat - cron | crontab -u kiosk -
rm -rf cron
service cron restart
sed -i -e 's/crontab_installed=0/crontab_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Crontab already installed. Skipping...${NC}\n"
fi



# Ubuntu loading theme
echo -e "${red}Customizing base theme...${NC}\n"
if [ "$plymouth_theme_installed" == 0 ]
then
mkdir /lib/plymouth/themes/kiosk
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/lib/plymouth/themes/kiosk/dig.png -O /lib/plymouth/themes/kiosk/dig.png
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/lib/plymouth/themes/kiosk/kiosk.plymouth -O /lib/plymouth/themes/kiosk/kiosk.plymouth
wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/lib/plymouth/themes/kiosk/kiosk.script -O /lib/plymouth/themes/kiosk/kiosk.script
#wget -q https://raw.githubusercontent.com/mmihalev/kiosk/master/usr/share/initramfs-tools/scripts/functions -O /usr/share/initramfs-tools/scripts/functions
update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/kiosk/kiosk.plymouth 100
#update-alternatives --config default.plymouth
update-initramfs -u
sed -i -e 's/plymouth_theme_installed=0/plymouth_theme_installed=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Base theme already installed. Skipping...${NC}\n"
fi



# Set correct user and group permissions for /home/kiosk
echo -e "${red}Set correct user and group permissions for ${blue}/home/kiosk${red}...${NC}\n"
if [ "$kiosk_permissions" == 0 ]
then
chown -R kiosk.kiosk /home/kiosk/
sed -i -e 's/kiosk_permissions=0/kiosk_permissions=1/g' stages.cfg
echo -e "${green}Done!${NC}\n"
else
	echo -e "${blue}Permissions already set. Skipping...${NC}\n"
fi



#Choose kiosk mode
echo -e "${green}Choose Kiosk Mode:${NC}"
PS3="Type 1, 2 or 3:"
options=("Video mode" "Photo mode" "Browser mode")
select opt in "${options[@]}"
do
	case $opt in
		"Video mode")
			echo -e "${green}Configuring the kiosk in Video mode...${NC}"
			sed -i -e 's/enable_videos="False"/enable_videos="True"/g' /home/kiosk/.kiosk/videos.cfg
			sed -i -e 's/\\"enable_videos\\": false/\\"enable_videos\\": true/g' /etc/ajenti/config.json
			
			sed -i -e 's/xscreensaver_enable="True"/xscreensaver_enable="False"/g' /home/kiosk/.kiosk/screensaver.cfg
			sed -i -e 's/\\"xscreensaver_enable\\": true/\\"xscreensaver_enable\\": false/g' /etc/ajenti/config.json
			
			sed -i -e 's/enable_browser="True"/enable_browser="False"/g' /home/kiosk/.kiosk/browser.cfg
			sed -i -e 's/\\"enable_browser\\": true/\\"enable_browser\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		"Photo mode")
			echo -e "${green}Configuring the kiosk in Photo mode...${NC}"
			sed -i -e 's/xscreensaver_enable="False"/xscreensaver_enable="True"/g' /home/kiosk/.kiosk/screensaver.cfg
			sed -i -e 's/\\"xscreensaver_enable\\": false/\\"xscreensaver_enable\\": true/g' /etc/ajenti/config.json
			
			sed -i -e 's/enable_videos="True"/enable_videos="False"/g' /home/kiosk/.kiosk/videos.cfg
			sed -i -e 's/\\"enable_videos\\": true/\\"enable_videos\\": false/g' /etc/ajenti/config.json
			
			sed -i -e 's/enable_browser="True"/enable_browser="False"/g' /home/kiosk/.kiosk/browser.cfg
			sed -i -e 's/\\"enable_browser\\": true/\\"enable_browser\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		"Browser mode")
			echo -e "${green}Configuring the kiosk in Browser mode...${NC}"
			sed -i -e 's/enable_browser="False"/enable_browser="True"/g' /home/kiosk/.kiosk/browser.cfg
			sed -i -e 's/\\"enable_browser\\": false/\\"enable_browser\\": true/g' /etc/ajenti/config.json
			
			sed -i -e 's/enable_videos="True"/enable_videos="False"/g' /home/kiosk/.kiosk/videos.cfg
			sed -i -e 's/\\"enable_videos\\": true/\\"enable_videos\\": false/g' /etc/ajenti/config.json
			
			sed -i -e 's/xscreensaver_enable="True"/xscreensaver_enable="False"/g' /home/kiosk/.kiosk/screensaver.cfg
			sed -i -e 's/\\"xscreensaver_enable\\": true/\\"xscreensaver_enable\\": false/g' /etc/ajenti/config.json
			
			echo -e "${green}Done!${NC}\n"
			break
			;;
		*) echo -e "${red}Invalid Option. Please, choose 1, 2 or 3${NC}";;
	esac
done

# Choose kiosk name
kiosk_name=""
while [[ ! $kiosk_name =~ ^[A-Za-z0-9]+$ ]]; do
    echo -e "${green}Kiosk name (e.g. kiosk1):${NC}"
    read kiosk_name
done

old_hostname="$( hostname )"

if [ -n "$( grep "$old_hostname" /etc/hosts )" ]; then
    sed -i "s/$old_hostname/$kiosk_name/g" /etc/hosts
else
    echo -e "$( hostname -I | awk '{ print $1 }' )\t$kiosk_name" >> /etc/hosts
fi

sed -i "s/$old_hostname/$kiosk_name/g" /etc/hostname
echo -e "${blue}Kiosk hostname set to: ${kiosk_name}${NC}"


echo -e "${green}Reboot?${NC}"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
                        reboot ;;
                No )
                        break ;;
        esac
done
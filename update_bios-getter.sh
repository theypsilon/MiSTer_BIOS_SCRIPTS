#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


#Simple scripts to automate downloading BIOS files for MiSTer console cores based on your rbf files.

#Instructions:

#Download the update_bios-getter.sh to the Scripts directory and run:

#update_bios-getter.sh

#These scripts look at what RBFconsole core files you have and downloads the bios needed for them.

#These scripts DO NOT download any cores.

#Q:Will this script over write files I already have?

#A: NO, This script will not clober files you already have. You need to manaully remove any files you have if you want to download new files BIOS files for the core.

#Q: Where are the Downloaded BIOS files located?

#A: This script downloads all bios files to /media/fat/BIOS. Symlinks are used in the consoles games directory to link back to the BIOS directory.

#Q: Can I set a custom BIOS directory location.

#A: Yes, in the update_bios-getter.ini: BIOSDIR=/path/to/your/location

#Q: Can I set this to work with usb drives?

#A: yes,in the update_bios-getter.ini: GAMESDIR=/media/usb0/games

#You should back up your bios files before running this script.

#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY KILL BABY SEALS.

#####################################################################################################
SSL_SECURITY_OPTION=""
curl ${CURL_RETRY} "https://github.com" > /dev/null 2>&1
case $? in
    0) ;;
    60) SSL_SECURITY_OPTION="--insecure" ;;
    *)
        echo "No Internet connection"
        exit 1
        ;;
esac
export SSL_SECURITY_OPTION

echo "STARTING CONSOLE-BIOS-GETTER"
echo ""

echo "Downloading the most recent bios-getter.sh script."
echo " "
CURL_RETRY="--connect-timeout 15 --max-time 60 --retry 3 --retry-delay 5 --show-error"
curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location -o /tmp/bios-getter.sh https://github.com/MAME-GETTER/MiSTer_BIOS_SCRIPTS/raw/master/bios-getter.sh
chmod +x /tmp/bios-getter.sh

/tmp/bios-getter.sh

rm /tmp/bios-getter.sh

echo "FINISHED: CONSOLE-BIOS-GETTER"

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

#Download the update_console-bios-getter.sh to the Scripts directory and run:

#update_console-bios-getter.sh

#These scripts look at what RBFconsole core files you have and downloads the bios needed for them.

#These scripts DO NOT download any cores.

#Q:Will this script over write files I already have?

#A: NO, This script will not clober files you already have. You need to manaully remove any files you have if you want to download new files BIOS files for the core.

#Q: Where are the Downloaded BIOS files located?

#A: This script downloads all bios files to /media/fat/BIOS. Symlinks are used in the consoles games directory to link back to the BIOS directory.

#Q: Can I set a custom BIOS directory location.

#A: Yes, in the update_console-bios-getter.ini: BIOS_DIR=/path/to/your/location

#Q: Can I set this to work with usb drives?

#A: yes,in the update_console-bios-getter.ini: COREPARTITON=/media/usb0

#You should back up your bios files before running this script.

#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY KILL BABY SEALS.

####################################################################################################
export CURL_RETRY
export ALLOW_INSECURE_SSL
export SSL_SECURITY_OPTION

echo "STARTING CONSOLE-BIOS-GETTER"
echo ""

echo "Downloading the most recent console-bios-getter.sh script."
echo " "
wget -q -t 3 --output-file=/tmp/wget-log --show-progress -O /tmp/console-bios-getter.sh https://github.com/MAME-GETTER/MiSTer_BIOS_SCRIPTS/raw/master/console-bios-getter.sh

chmod +x /tmp/console-bios-getter.sh

/tmp/console-bios-getter.sh

rm /tmp/console-bios-getter.sh

echo "FINISHED: CONSOLE-BIOS-GETTER"

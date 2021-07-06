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

#Q:Will this script over write any files I already have?

#A: NO. This script will not clobber files you already have. You need to manaully remove any BIOS files you have if you want to download new files BIOS files for the core.

#Q: Where are the Downloaded BIOS files located?

#A: This script downloads all bios files to /media/fat/BIOS. Symlinks are used in the consoles games directory to link back to the BIOS directory.

#Q: Can I set a custom BIOS directory location.

#A: Yes, in the update_bios-getter.ini: BIOSDIR=/path/to/your/location

#Q: Can I set this to work with usb drives?

#A: Yes, in the update_bios-getter.ini: GAMESDIR=/media/usb0/games

#You should back up your bios files before running this script.

#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTY AND MAY KILL BABY SEALS.

echo "STARTING BIOS-GETTER"
echo ""
# ========= OPTIONS ==================
ALLOW_INSECURE_SSL="true"
CURL_RETRY="--connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5 --show-error"
# ========= CODE STARTS HERE =========

INI_PATH="$(pwd)/update_bios-getter.ini"
if [ -f "${INI_PATH}" ] ; then
    TMP=$(mktemp)
    dos2unix < "${INI_PATH}" 2> /dev/null | grep -v "^exit" > ${TMP} || true

    if [ $(grep -c "ALLOW_INSECURE_SSL=" "${TMP}") -gt 0 ] ; then
        ALLOW_INSECURE_SSL=$(grep "ALLOW_INSECURE_SSL=" "${TMP}" | awk -F "=" '{print$2}' | sed -e 's/^ *// ; s/ *$// ; s/^"// ; s/"$//')
    fi 2> /dev/null

    if [ $(grep -c "CURL_RETRY=" "${TMP}") -gt 0 ] ; then
        CURL_RETRY=$(grep "CURL_RETRY=" "${TMP}" | awk -F "=" '{print$2}' | sed -e 's/^ *// ; s/ *$// ; s/^"// ; s/"$//')
    fi 2> /dev/null

    rm ${TMP}
fi

#####################################################################################################
SSL_SECURITY_OPTION=""

set +e
curl ${CURL_RETRY} "https://github.com" > /dev/null 2>&1
RET_CURL=$?
set -e

case ${RET_CURL} in
    0)
        ;;
    *)
        if [[ "${ALLOW_INSECURE_SSL}" == "true" ]]
        then
            SSL_SECURITY_OPTION="--insecure"
        else
            echo "CA certificates need"
            echo "to be fixed for"
            echo "using SSL certificate"
            echo "verification."
            echo "Please fix them i.e."
            echo "using security_fixes.sh"
            exit 2
        fi
        ;;
    *)
        echo "No Internet connection"
        exit 1
        ;;
esac

BIOS_GETTER="bios-getter.sh"
URL="https://github.com/theypsilon/MiSTer_BIOS_SCRIPTS/raw/master/"
echo "Downloading the most recent ${BIOS_GETTER} script."
echo ""

curl \
    --location \
    --connect-timeout 15 \
    --max-time 60 \
    --retry 3 \
    --retry-delay 5 \
    --show-error \
    ${SSL_SECURITY_OPTION} \
    --output /tmp/${BIOS_GETTER} \
    ${URL}${BIOS_GETTER}

export CURL_RETRY
export ALLOW_INSECURE_SSL
export SSL_SECURITY_OPTION

bash /tmp/${BIOS_GETTER} && rm /tmp/${BIOS_GETTER}

echo "FINISHED: BIOS-GETTER"

exit 0

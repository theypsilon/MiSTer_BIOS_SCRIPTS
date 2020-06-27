#!/bin/bash
#set -x

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


BIOSDIR="/media/fat/BIOS"
GAMESDIR="/media/fat/games"
BASE_PATH="/media/fat"
OVERWRITE_GAMES_BIOS="true"
SSL_SECURITY_OPTION="${SSL_SECURITY_OPTION:---insecure}"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5 --show-error"
INIFILE="/media/fat/Scripts/update_console-bios-getter.ini"
EXITSTATUS=0
# Needs to be changed when a new zip has been uploaded with updated content
RESOURCES_DATE="$(date -d '2020-06-14 16:35')"

#########Get Script - uncomment for release 
find /media/fat/ -maxdepth 5 -type d -name Scripts | sort -u | while read g
do 
if [ ! -e "$g/update_console-bios-getter.sh" ]
	then
		echo "Downloading update_console-bios-getter.sh to "$g""Q	Q
        echo ""
		curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location -o "$g/update_console-bios-getter.sh" https://github.com/MAME-GETTER/MiSTer_BIOS_SCRIPTS/raw/master/update_console-bios-getter.sh

fi
done

INIFILE_FIXED=$(mktemp)
if [[ -f "${INIFILE}" ]] ; then
	dos2unix < "${INIFILE}" 2> /dev/null > ${INIFILE_FIXED}
fi


if [ `grep -c "BIOSDIR=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      BIOSDIR=`grep "BIOSDIR=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null 

if [ `grep -c "GAMESDIR=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      GAMESDIR=`grep "GAMESDIR=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null 

if [ `grep -c "BASE_PATH=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      BASE_PATH=`grep "BASE_PATH=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null
if [ `grep -c "OVERWRITE_GAMES_BIOS=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      OVERWRITE_GAMES_BIOS=`grep "OVERWRITE_GAMES_BIOS=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null 
#####INFO TXT#####

if [ `egrep -c "BIOSDIR|GAMESDIR|BASE_PATH|OVERWRITE_GAMES_BIOS" "${INIFILE_FIXED}"` -gt 0 ]
   then
      echo ""
      echo "Using "${INIFILE}"" 
      echo ""
fi 2>/dev/null 

rm ${INIFILE_FIXED}


GETTER ()

{
	local SYSTEM="${1}"
	local BOOTROM="${2}"
	local ZIPURL="${3}"
	local BIOSLINK="${4}"

	local SYSTEM_FOLDER=$(find "${GAMESDIR}" -maxdepth 1 -type d -iname "${SYSTEM}" -printf "%P\n" -quit)
	
	if [[ "${SYSTEM_FOLDER}" != "" ]]
		then
			echo ""
			echo "STARTING BIOS RETRIVAL FOR: $SYSTEM_FOLDER" 
			echo ""
			GETTER_INTERNAL "${SYSTEM_FOLDER}" "${BOOTROM}" "${ZIPURL}" "${BIOSLINK}"
			echo ""
	else
			echo "Please create a "$GAMESDIR/$SYSTEM" directory" >> /tmp/dir.errors
	fi	
			echo ""
			echo "##################################################################"
}


GETTER_INTERNAL () 

{ 
	local SYSTEM_FOLDER="${1}"
	local BOOTROM="${2}"
	local ZIPURL="${3}"
	local BIOSLINK="${4}"

	PATHBOOTROM="$GAMESDIR/$SYSTEM_FOLDER/$BOOTROM"
	if [ -e "$PATHBOOTROM" ]
		then
			echo "Nothing to be done."
			echo "Skipped '$PATHBOOTROM' because already exists." >> /tmp/bios.info 
		else

			local ZIPPATH="$(basename ${ZIPURL})"

			if [ ! -d "$BIOSDIR/${ZIPPATH%.*}" ] ; then
				mkdir -vp "$BIOSDIR/${ZIPPATH%.*}"
				echo ""

				curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --fail --location -o "$BIOSDIR"/"${ZIPPATH}" "${ZIPURL}"
				echo ""
				unzip -o -j "$BIOSDIR/${ZIPPATH}" -d "$BIOSDIR/${ZIPPATH%.*}/"
				echo ""

				rm "$BIOSDIR/${ZIPPATH}" 2> /dev/null
				touch "$BIOSDIR/${ZIPPATH}"
			fi

			cp -vn "$BIOSDIR/${ZIPPATH%.*}/$BIOSLINK" "$GAMESDIR/$SYSTEM_FOLDER/$BOOTROM"
			[ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for $SYSTEM_FOLDER" >> /tmp/bios.errors
	fi
}


ITERATE_CONSOLES ()

{
	#FIND CONSOLES
	find $BASE_PATH/_Console/ -maxdepth 5 -iname \*rbf  -path *_Console* > /tmp/bios-getter.file
	echo "Consoles Found:"
	cat /tmp/bios-getter.file
	echo "" 
	echo "Stating to look for needed bios files"
	sleep 2 
	echo
	echo
	echo "##################################################################"
	cat /tmp/bios-getter.file| while read i 
	do 

		local LINE=`basename "$i"`
		local SYSTEM=`echo "${LINE::-13}"`
		local LOWERCASE_SYSTEM=$(echo "${SYSTEM}" | awk '{print tolower($0)}')
		#echo $SYSTEM
		
		case "${LOWERCASE_SYSTEM}" in
			astrocade)
				GETTER "${SYSTEM}" 'boot.rom' \
				'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/Astrocade.zip' \
				"Bally Professional Arcade, Astrocade '3159' BIOS (1978)(Bally Mfg. Corp.).bin"
				;;

			gameboy)
				GETTER "${SYSTEM}" 'boot1.rom' \
				'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/Gameboy.zip' \
				'GB_boot_ROM.gb'
				;;

			megacd)
				GETTER "${SYSTEM}" 'boot.rom' \
				'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/MegaCD.zip' \
				'US Sega CD 2 (Region Free) 930601 l_oliveira.bin'
				;;

			turbografx16)
				mkdir -p "${GAMESDIR}/TGFX16-CD"
				GETTER 'TGFX16-CD' 'cd_bios.rom' \
				'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/TurboGrafx16.zip' \
				'Super CD 3.0.pce'
				;;

			nes)
				GETTER "${SYSTEM}" 'boot0.rom' \
				'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/NES.zip' \
				'fds-bios.rom'
				;;

			neogeo)

				local BOOTROM='000-lo.lo'
				local ZIPURL='https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/NeoGeo.zip'
				local BIOSLINK='000-lo.lo'

				local SYSTEM_FOLDER=$(find "${GAMESDIR}" -maxdepth 1 -type d -iname "${SYSTEM}" -printf "%P\n" -quit)
				
				if [[ "${SYSTEM_FOLDER}" != "" ]]
					then
						rm /tmp/neogeo.bios.file 2> /dev/null
						grep "NEOGEO-BIOS:" "$0" | sed 's/NEOGEO-BIOS://' | while read z
						do 
							if [ -e "$GAMESDIR/${SYSTEM_FOLDER}/$z" ] 
								then
									echo "  $GAMESDIR/${SYSTEM_FOLDER}/$z" >> /tmp/neogeo.bios.file   i
							fi
						done

								echo ""
								echo "STARTING BIOS RETRIVAL FOR: NEOGEO"
								echo "" 

						if [ -e /tmp/neogeo.bios.file ] 
							then
								echo "Skipped 'NeoGeo' because following files already exists:" >> /tmp/bios.info
								cat /tmp/neogeo.bios.file >> /tmp/bios.info
							else
								GETTER_INTERNAL "${SYSTEM_FOLDER}" "${BOOTROM}" "${ZIPURL}" "${BIOSLINK}"

								if [ ! -f "$BIOSDIR/uni-bios-40.zip" ]
									then
										curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --fail --location -o "$BIOSDIR/uni-bios-40.zip" http://unibios.free.fr/download/uni-bios-40.zip 
										echo " "
										unzip -o -j "$BIOSDIR/uni-bios-40.zip" -d "$BIOSDIR/NeoGeo/"
										rm "$BIOSDIR/uni-bios-40.zip"
										touch "$BIOSDIR/uni-bios-40.zip"
								fi

								cp -vn "$BIOSDIR/NeoGeo/sfix.sfix" "$GAMESDIR/$SYSTEM_FOLDER/sfix.sfix"
												[ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for $SYSTEM_FOLDER" >> /tmp/bios.errors
							
								cp -vn "$BIOSDIR/NeoGeo/uni-bios.rom" "$GAMESDIR/$SYSTEM_FOLDER/uni-bios.rom"
								[ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for $SYSTEM_FOLDER" >> /tmp/bios.errors
												echo " "
								echo ""
						fi

					else
								echo "Please create a "$GAMESDIR/$SYSTEM" directory" >> /tmp/dir.errors
				fi
								echo "##################################################################"
				;;
		esac

	done 
}


############### START ################

#clean up errors file if it exist
rm -v /tmp/bios.errors 2> /dev/null
rm -v /tmp/bios.info 2> /dev/null
rm -v /tmp/dir.errors 2> /dev/null

if [ ! -f "${BIOSDIR}/date" ] || [[ "${RESOURCES_DATE}" > "$(cat ${BIOSDIR}/date)" ]]; then
	rm -rf "${BIOSDIR}" 2> /dev/null
	echo "BIOS folder is not yet installed or is not up-to-date."
	echo
fi

mkdir -p "$BIOSDIR"

ITERATE_CONSOLES
    
if [ -e /tmp/bios.info ]
	then
 		echo "Please remove the existing BIOS files for the console and rerun the script if you want them updated. If you want to keep the current BIOS files no action is needed."
      	cat /tmp/bios.info
		rm /tmp/bios.info
fi 

if [ -e /tmp/bios.errors ]
	then
 		echo "Following errors ocurred."
      	cat /tmp/bios.errors
		rm /tmp/bios.errors
        EXITSTATUS=1 
fi 

if [ -e /tmp/dir.errors ]
	then
		echo ""
		echo "The following directoires are need for this script. Please create and orgaize your roms/files in the following directoies."
		cat /tmp/dir.errors
		rm /tmp/dir.errors
		EXITSTATUS=1
fi

#clean up zip files 
if [ -e "$BIOSDIR/*.zip" ]
	then
	    rm "$BIOSDIR/*.zip"
fi

if [[ "${EXITSTATUS}" == "0" ]] && [ ! -f "${BIOSDIR}/date" ]
	then
		echo "${RESOURCES_DATE}" > "${BIOSDIR}/date"
fi

exit $EXITSTATUS

#NEOGEO-BIOS 
NEOGEO-BIOS:000-lo.lo
NEOGEO-BIOS:japan-j3.bin
NEOGEO-BIOS:sfix.sfix
NEOGEO-BIOS:sm1.sm1
NEOGEO-BIOS:sp1-j3.bin
NEOGEO-BIOS:sp1.jipan.1024
NEOGEO-BIOS:sp1-u2
NEOGEO-BIOS:sp1-u3.bin
NEOGEO-BIOS:sp1-u4.bin
NEOGEO-BIOS:sp-1v1_3db8c
NEOGEO-BIOS:sp-45.sp1
NEOGEO-BIOS:sp-e.sp1
NEOGEO-BIOS:sp-j2.sp1
NEOGEO-BIOS:sp-j3.sp1
NEOGEO-BIOS:sp-s2.sp1
NEOGEO-BIOS:sp-s3.sp1
NEOGEO-BIOS:sp-s.sp1
NEOGEO-BIOS:sp-u2.sp1
NEOGEO-BIOS:uni-bios*rom
NEOGEO-BIOS:vs-bios.rom

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
COREPARTITION="/media/fat"
SSL_SECURITY_OPTION="--insecure"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5 --show-error"
INIFILE="/media/fat/Scripts/update-console-bios-getter.ini"
EXITSTATUS=0

#More testing crap - this will be removed at release  
#rm /media/fat/Scripts/update-console-bios-getter.sh 
#########################
#
echo""

#########Get Script - uncomment for release 
find /media/ -maxdepth 5 -type d -name Scripts | sort -u | while read g
do 
if [ ! -e "$g/update-console-bios-getter.sh" ]
	then
		echo ""
		echo "Downloading update-console-bios-getter.sh to "$g""
                echo ""
		curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location -o "$g/update-console-bios-getter.sh" https://github.com/MAME-GETTER/MiSTer_BIOS_SCRIPTS/raw/master/update-console-bios-getter.sh

fi
done

#TESTING CRAP - THIS WILL BE REMOVED AT THE RELEASE 
#rm -rf /media/fat/BIOS
#unlink /media/fat/games/Astrocade/boot.rom
#unlink /media/fat/games/Gameboy/boot1.rom
#unlink /media/fat/games/MegaCD/boot.rom
#unlink /media/fat/games/NeoGeo/000-lo.lo
#unlink /media/fat/games/NeoGeo/sfix.sfix
#unlink /media/fat/games/NeoGeo/uni-bios.rom
#unlink /media/fat/games/TGFX16-CD/cd_bios.rom
#unlink /media/fat/games/NES/boot0.rom 
#END TESTING CRAP

#####INI FILES VARS######

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

if [ `grep -c "COREPARTITION=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      COREPARTITION=`grep "COREPARTITION=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null 
#####INFO TXT#####

if [ `egrep -c "BIOSDIR|GAMESDIR|COREPARTITION" "${INIFILE_FIXED}"` -gt 0 ]
   then
      echo ""
      echo "Using "${INIFILE}"" 
      echo ""
fi 2>/dev/null 

rm ${INIFILE_FIXED}

#clean up errors file if it exist
rm -v /tmp/bios.errors 2> /dev/null
rm -v /tmp/dir.errors 2> /dev/null

mkdir -p $BIOSDIR

echo ""

#FIND CONSOLES
find $COREPARTITION/_Console/ -maxdepth 5 -iname \*rbf  -path *_Console* > /tmp/bios-getter.file
echo ""
echo "Consoles Found:"
cat /tmp/bios-getter.file
echo "" 
echo "Stating to look for needed bios files"
sleep 5 
cat /tmp/bios-getter.file| while read i 
do 

LINE=`basename "$i"`
SYSTEM=`echo "${LINE::-13}"`
#echo $SYSTEM

GETTER () 

{ echo ""
echo "STARTING BIOS RETRVAL FOR: $SYSTEM" 
echo ""

PATHBOOTROM="$GAMESDIR/$SYSTEM/$BOOTROM"
if [ -e "$PATHBOOTROM" ] || [ -e $GAMESDIR/TGFX16-CD/cd_bios.rom ]
                        then
                                echo "The $SYSTEM $BOOTROM already exists, please remove and rerun the script if you want them updated."
				echo "$PATHBOOTROM"
			       	echo "ERROR: BIOS was not able to be set for $SYSTEM" >> /tmp/bios.errors 
                        else

				mkdir -vp "$BIOSDIR/$SYSTEM"
				echo ""
				curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --fail --location -o "$BIOSDIR"/"$SYSTEM".zip https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/"$SYSTEM".zip 
                	        echo ""
				unzip -o -j "$BIOSDIR/$SYSTEM.zip" -d "$BIOSDIR/$SYSTEM/"
                        	echo ""
                        	echo "Linking to:"
                       		if [ $SYSTEM != TurboGrafx16 ]
					then
                        			cp -v "$BIOSDIR/$SYSTEM/$BIOSLINK" "$GAMESDIR/$SYSTEM/$BOOTROM"
                                                [ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for $SYSTEM" >> /tmp/bios.errors 
					else 
						
                        			cp -v "$BIOSDIR/$SYSTEM/$BIOSLINK" "$GAMESDIR/TGFX16-CD/$BOOTROM"	
						[ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for TGFX16" >> /tmp/bios.errors 
				fi

                echo ""
fi
} 
	

case "$SYSTEM" in
	Astrocade)
		BIOSLINK='Bally Professional Arcade, Astrocade '3159' BIOS (1978)(Bally Mfg. Corp.).bin' 
		BOOTROM='boot.rom'
		if [ -e "$GAMESDIR/$SYSTEM/" ]
			then
                		GETTER
		else
				echo "Please create a "$GAMESDIR/$SYSTEM" directory" >> /tmp/dir.errors
		fi	
                echo ""
                echo "##################################################################"
  ;;
	Gameboy)
                BIOSLINK='GB_boot_ROM.gb' 
                BOOTROM='boot1.rom'	
		if [ -e "$GAMESDIR/$SYSTEM/" ]
			then
                		GETTER
		else
				echo "Please create a "$GAMESDIR/$SYSTEM" directory" >> /tmp/dir.errors
		fi	
                echo ""
                echo "##################################################################"
 
  ;;
      MegaCD)
                BIOSLINK='US Sega CD 2 (Region Free) 930601 l_oliveira.bin' 
                BOOTROM='boot.rom'
		if [ -e "$GAMESDIR/$SYSTEM/" ]
			then
                		GETTER
		else
				echo "Please create a "$GAMESDIR/$SYSTEM" directory" >> /tmp/dir.errors
		fi	
                echo ""
                echo "##################################################################"
  ;;

TurboGrafx16)
		BIOSLINK='Super CD 3.0.pce'
                BOOTROM='cd_bios.rom'
		if [ -e "$GAMESDIR/TGFX16-CD/" ]
			then
                		GETTER
		else
				echo "Please create a "$GAMESDIR/TGFX16-CD" directory" >> /tmp/dir.errors
		fi	
                echo ""
                echo "##################################################################"
  ;;

	 NES) 
                BIOSLINK='fds-bios.rom'
                BOOTROM='boot0.rom'
		if [ -e "$GAMESDIR/$SYSTEM/" ]
			then
                		GETTER
		else
				echo "Please create a "$GAMESDIR/$SYSTEM" directory" >> /tmp/dir.errors
		fi	
                echo ""
                echo "##################################################################"

  ;;
      NeoGeo)
		SKIPNEOGEO=0
                BIOSLINK='000-lo.lo'
		BOOTROM='000-lo.lo'
		if [ -e "$GAMESDIR/$SYSTEM/" ]
		then
                rm /tmp/neogeo.bios.file 2> /dev/null
                grep "NEOGEO-BIOS:" "$0" | sed 's/NEOGEO-BIOS://' | while read z
                do 
                if [ -e "$GAMESDIR/$SYSTEM/$z" ] 
			then	
				echo "$GAMESDIR/$SYSTEM/$z" > /tmp/neogeo.bios.file   
		
                fi
                done 
                
		if [ -e /tmp/neogeo.bios.file ] 
			then
				echo ""
				echo "STARTING BIOS RETRVAL FOR: NEOGEO"
				echo "" 
				echo "Please please remove the following files and rerun the script if you want them updated." 
                        	cat /tmp/neogeo.bios.file
				echo ""
				echo "ERROR: BIOS was not able to be set for $SYSTEM" >> /tmp/bios.errors
                
			else
				GETTER
				curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --fail --location -o "$BIOSDIR/uni-bios-40.zip" http://unibios.free.fr/download/uni-bios-40.zip 
				echo " "
				unzip -o -j "$BIOSDIR/uni-bios-40.zip" -d "$BIOSDIR/$SYSTEM/"
				echo "Linking to:"
				cp -v "$BIOSDIR/$SYSTEM/sfix.sfix" "$GAMESDIR/$SYSTEM/sfix.sfix"
                                [ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for $SYSTEM" >> /tmp/bios.errors
				echo "Linking to:"
				cp -v "$BIOSDIR/$SYSTEM/uni-bios.rom" "$GAMESDIR/$SYSTEM/uni-bios.rom"
				[ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for $SYSTEM" >> /tmp/bios.errors
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
    
if [ -e /tmp/bios.errors ]
	then
 		echo "Please remove the existing BIOS files for the console and rerun the script if you want them updated. If you want to keep the current BIOS files no action is needed."
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


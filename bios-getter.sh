#!/bin/bash
#set -x
set -u

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
######################################################################

BIOSDIR="/media/fat/BIOS"
GAMESDIR="/media/fat/games"
SSL_SECURITY_OPTION="${SSL_SECURITY_OPTION:---insecure}"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5 --show-error"
INIFILE="/media/fat/Scripts/update_bios-getter.ini"
EXITSTATUS=0

#########Get Script
if [ ! -e "/media/fat/Scripts/update_bios-getter.sh" ]
    then
        echo "Downloading update_bios-getter.sh to /media/fat/Scripts"
        echo ""
        curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location -o "/media/fat/Scripts/update_bios-getter.sh" https://github.com/MAME-GETTER/MiSTer_BIOS_SCRIPTS/raw/master/update_bios-getter.sh
        echo
fi

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
#####INFO TXT#####

if [ `egrep -c "BIOSDIR|GAMESDIR" "${INIFILE_FIXED}"` -gt 0 ]
    then
        echo ""
        echo "Using "${INIFILE}"" 
        echo ""
fi 2>/dev/null 

rm ${INIFILE_FIXED}

SYSTEMS_WITH_BIOS=( \
    Astrocade \
    Gameboy \
    GBA \
    MegaCD \
    NeoGeo \
    NES \
    TurboGrafx16 \
)

NEOGEO_BIOS=( \
    "000-lo\.lo" \
    "japan-j3\.bin" \
    "sfix\.sfix" \
    "sm1\.sm1" \
    "sp1-j3\.bin" \
    "sp1\.jipan\.1024" \
    "sp1-u2" \
    "sp1-u3\.bin" \
    "sp1-u4\.bin" \
    "sp-1v1_3db8c" \
    "sp-45\.sp1" \
    "sp-e\.sp1" \
    "sp-j2\.sp1" \
    "sp-j3\.sp1" \
    "sp-s2\.sp1" \
    "sp-s3\.sp1" \
    "sp-s\.sp1" \
    "sp-u2\.sp1" \
    "uni-bios.*\.rom" \
    "vs-bios\.rom" \
)

NOTHING_TO_BE_DONE_MSG="Nothing to be done."

GETTER ()

{
    local SYSTEM="${1}"
    local BOOT_ROM="${2}"
    local ZIP_URL="${3}"
    local BIOS_ROM="${4}"

    local SYSTEM_FOLDER=$(GET_SYSTEM_FOLDER "${SYSTEM}")
    
    if [[ "${SYSTEM_FOLDER}" != "" ]]
        then
            echo ""
            echo "STARTING BIOS RETRIVAL FOR: $SYSTEM_FOLDER" 
            echo ""
            GETTER_INTERNAL "${SYSTEM_FOLDER}" "${BOOT_ROM}" "${ZIP_URL}" "${BIOS_ROM}"
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
    local BOOT_ROM="${2}"
    local ZIP_URL="${3}"
    local BIOS_ROM="${4}"

    local GAMES_TARGET="$GAMESDIR/$SYSTEM_FOLDER/$BOOT_ROM"
    if [ -e "$GAMES_TARGET" ]
        then
            echo "${NOTHING_TO_BE_DONE_MSG}"
            echo "Skipped '$GAMES_TARGET' because already exists." >> /tmp/bios.info 
        else

            local ZIP_PATH="$(basename ${ZIP_URL})"
            local BIOS_SOURCE="$BIOSDIR/${ZIP_PATH%.*}/$BIOS_ROM"

            if [ ! -f "$BIOS_SOURCE" ] ; then
                mkdir -vp "$BIOSDIR/${ZIP_PATH%.*}"
                echo ""

                curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --fail --location -o "$BIOSDIR"/"${ZIP_PATH}" "${ZIP_URL}"
                echo ""
                unzip -o -j "$BIOSDIR/${ZIP_PATH}" -d "$BIOSDIR/${ZIP_PATH%.*}/"
                echo ""

                rm "$BIOSDIR/${ZIP_PATH}" 2> /dev/null
            fi

            INSTALL "$BIOS_SOURCE" "$GAMES_TARGET" "$SYSTEM_FOLDER"
    fi
}


GET_SYSTEM_FOLDER()

{
    local SYSTEM="${1}"
    find "${GAMESDIR}" -maxdepth 1 -type d -iname "${SYSTEM}" -printf "%P\n" -quit
}


INSTALL ()

{
    local BIOS_SOURCE="${1}"
    local GAMES_TARGET="${2}"
    local SYSTEM="${3}"

    cp -vn "$BIOS_SOURCE" "$GAMES_TARGET"
    [ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for $SYSTEM" >> /tmp/bios.errors
}


INSTALL_MEGACD_REGION ()

{
    local SYSTEM_FOLDER="${1}"
    local BIOS_SOURCE="${2}"
    local REGION="${3}"

    local GAMES_TARGET="${GAMESDIR}/${SYSTEM_FOLDER}/${REGION}/cd_bios.rom"
    if [ -f "${GAMES_TARGET}" ] ; then
        echo "Skipped '$GAMES_TARGET' because already exists." >> /tmp/bios.info
    elif [ -f "${BIOS_SOURCE}" ] ; then
        mkdir -p "${GAMESDIR}/${SYSTEM_FOLDER}/${REGION}"
        INSTALL "${BIOS_SOURCE}" "${GAMES_TARGET}" "${SYSTEM_FOLDER}"
    fi
}


ITERATE_SYSTEMS ()

{
    echo ""
    echo "Systems checked:"
    printf ' %s\n' "${SYSTEMS_WITH_BIOS[@]}"
    sleep 2 
    echo
    echo
    echo "##################################################################"
    for SYSTEM in ${SYSTEMS_WITH_BIOS[@]}
    do 
        local LOWERCASE_SYSTEM=$(echo "${SYSTEM}" | awk '{print tolower($0)}')
        
        case "${LOWERCASE_SYSTEM}" in
            astrocade)
                GETTER "${SYSTEM}" 'boot.rom' \
                'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/Astrocade.zip' \
                "Bally Professional Arcade, Astrocade '3159' BIOS (1978)(Bally Mfg. Corp.).bin"
                ;;

            gameboy)
                GETTER "${SYSTEM}" 'boot1.rom' \
                'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/Gameboy.zip' \
                'GBC_boot_ROM.gb'
                ;;

            gba)
                GETTER "${SYSTEM}" 'boot.rom' \
                'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/GBA.zip' \
                'gba_bios.bin'
                ;;

            megacd)
                local SYSTEM_FOLDER=$(GET_SYSTEM_FOLDER "${SYSTEM}")
                if [[ "${SYSTEM_FOLDER}" != "" ]]
                    then
                        echo ""
                        echo "STARTING BIOS RETRIVAL FOR: $SYSTEM_FOLDER"
                        echo ""
                        local BOOT_ROM='boot.rom'
                        local ZIP_URL='https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/MegaCD.zip'
                        local BIOS_ROM='US Sega CD 2 (Region Free) 930601 l_oliveira.bin'
                        local MEGACD_BIOSES=(
                            "${GAMESDIR}/${SYSTEM_FOLDER}/${BOOT_ROM}"
                            "${GAMESDIR}/${SYSTEM_FOLDER}/Japan/cd_bios.rom"
                            "${GAMESDIR}/${SYSTEM_FOLDER}/USA/cd_bios.rom"
                            "${GAMESDIR}/${SYSTEM_FOLDER}/Europe/cd_bios.rom"
                        )
                        local ALL_TRUE="true"
                        for bios in ${MEGACD_BIOSES[@]} ; do
                            [ -e "${bios}" ] || ALL_TRUE="false"
                        done
                        if [[ "${ALL_TRUE}" == "true" ]]
                        then
                            echo "${NOTHING_TO_BE_DONE_MSG}"
                            for bios in ${MEGACD_BIOSES[@]} ; do
                                echo "Skipped '${bios}' because already exists." >> /tmp/bios.info
                            done
                        else
                            local MESSAGE=$(GETTER_INTERNAL "${SYSTEM_FOLDER}" "${BOOT_ROM}" "${ZIP_URL}" "${BIOS_ROM}")
                            if [[ "${MESSAGE}" != "${NOTHING_TO_BE_DONE_MSG}" ]]; then
                                echo "${MESSAGE}"
                            fi
                            INSTALL_MEGACD_REGION "${SYSTEM_FOLDER}" "${BIOSDIR}/MegaCD/[BIOS] Mega-CD 2 (Japan) (v2.00C).md" "Japan"
                            INSTALL_MEGACD_REGION "${SYSTEM_FOLDER}" "${BIOSDIR}/MegaCD/[BIOS] Sega CD 2 (USA) (v2.00).md" "USA"
                            INSTALL_MEGACD_REGION "${SYSTEM_FOLDER}" "${BIOSDIR}/MegaCD/[BIOS] Mega-CD 2 (Europe) (v2.00).md" "Europe"
                        fi
                        echo
                else
                        echo "Please create a "$GAMESDIR/$SYSTEM" directory" >> /tmp/dir.errors
                fi
                        echo ""
                        echo "##################################################################"
                ;;

            neogeo)
                local SYSTEM_FOLDER=$(GET_SYSTEM_FOLDER "${SYSTEM}")
                
                if [[ "${SYSTEM_FOLDER}" != "" ]]
                    then
                        rm /tmp/neogeo.bios.file 2> /dev/null
                        for NEO_BIOS_REGEX in ${NEOGEO_BIOS[@]}
                        do
                            find "$GAMESDIR/${SYSTEM_FOLDER}/" -maxdepth 1 -type f -regextype grep -regex "$GAMESDIR/${SYSTEM_FOLDER}/${NEO_BIOS_REGEX}" | \
                            while read NEO_BIOS_PATH
                            do
                                echo "  $NEO_BIOS_PATH" >> /tmp/neogeo.bios.file
                            done
                        done

                                echo ""
                                echo "STARTING BIOS RETRIVAL FOR: NEOGEO"
                                echo "" 

                        if [ -e /tmp/neogeo.bios.file ] 
                            then
                                echo "${NOTHING_TO_BE_DONE_MSG}"
                                echo "Skipped 'NeoGeo' because following files already exists:" >> /tmp/bios.info
                                cat /tmp/neogeo.bios.file >> /tmp/bios.info
                            else
                                local BOOT_ROM='000-lo.lo'
                                local ZIP_URL='https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/NeoGeo.zip'
                                local BIOS_ROM='000-lo.lo'
                                GETTER_INTERNAL "${SYSTEM_FOLDER}" "${BOOT_ROM}" "${ZIP_URL}" "${BIOS_ROM}"

                                if [ ! -f "$BIOSDIR/NeoGeo/sfix.sfix" ] || [ ! -f "$BIOSDIR/NeoGeo/uni-bios.rom" ]
                                    then
                                        curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --fail --location -o "$BIOSDIR/uni-bios-40.zip" http://unibios.free.fr/download/uni-bios-40.zip 
                                        echo " "
                                        unzip -o -j "$BIOSDIR/uni-bios-40.zip" -d "$BIOSDIR/NeoGeo/"
                                        rm "$BIOSDIR/uni-bios-40.zip"
                                fi

                                INSTALL "$BIOSDIR/NeoGeo/sfix.sfix" "$GAMESDIR/$SYSTEM_FOLDER/sfix.sfix" "$SYSTEM_FOLDER"
                                INSTALL "$BIOSDIR/NeoGeo/uni-bios.rom" "$GAMESDIR/$SYSTEM_FOLDER/uni-bios.rom" "$SYSTEM_FOLDER"
                        fi
                        echo
                    else
                                echo "Please create a "$GAMESDIR/$SYSTEM" directory" >> /tmp/dir.errors
                fi
                                echo ""
                                echo "##################################################################"
                ;;

            nes)
                GETTER "${SYSTEM}" 'boot0.rom' \
                'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/NES.zip' \
                'fds-bios.rom'
                ;;

            turbografx16)
                mkdir -p "${GAMESDIR}/TGFX16-CD"
                GETTER 'TGFX16-CD' 'cd_bios.rom' \
                'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/TurboGrafx16.zip' \
                'Super CD 3.0.pce'
                ;;
        esac

    done 
}


############### START ################

#clean up errors file if it exist
rm -v /tmp/bios.errors 2> /dev/null
rm -v /tmp/bios.info 2> /dev/null
rm -v /tmp/dir.errors 2> /dev/null

mkdir -p "$BIOSDIR"

ITERATE_SYSTEMS

echo

if [ -e /tmp/bios.info ]
    then
        echo "Please remove the existing BIOS files for the system and rerun if you want them updated. If you want to keep the current BIOS files no action is needed."
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
        echo "The following directories are need for this script. Please create and organize your roms/files in the following directoies."
        cat /tmp/dir.errors
        rm /tmp/dir.errors
        EXITSTATUS=1
fi

echo

if [ $EXITSTATUS -eq 0 ]
    then
        echo "SUCCESS!"
else
        echo "Some error occurred."        
fi

echo

exit $EXITSTATUS

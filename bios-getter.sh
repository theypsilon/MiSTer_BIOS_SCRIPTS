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
INSTALL="false"
INIFILE="$(pwd)/update_bios-getter.ini"

SSL_SECURITY_OPTION="${SSL_SECURITY_OPTION:---insecure}"
CURL_RETRY="${CURL_RETRY:---connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5 --show-error}"

EXITSTATUS=0


INIFILE_FIXED=$(mktemp)
if [[ -f "${INIFILE}" ]] ; then
    dos2unix < "${INIFILE}" 2> /dev/null > ${INIFILE_FIXED}
fi


if [ `grep -c "BIOSDIR=" "${INIFILE_FIXED}"` -gt 0 ]
    then
        BIOSDIR=`grep "BIOSDIR=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null

if [ `grep -c "INSTALL=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      INSTALL=`grep "INSTALL=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null

if [ `grep -c "CURL_RETRY=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      CURL_RETRY=`grep "CURL_RETRY=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null

#####INFO TXT#####

if [ `egrep -c "BIOSDIR|INSTALL|CURL_RETRY" "${INIFILE_FIXED}"` -gt 0 ]
    then
        echo ""
        echo "Using "${INIFILE}"" 
        echo ""
fi 2>/dev/null 

rm ${INIFILE_FIXED}

#########Auto Install##########
if [[ "${INSTALL^^}" == "TRUE" ]] && [ ! -e "/media/fat/Scripts/update_bios-getter.sh" ]
   then
        echo "Downloading update_bios-getter.sh to /media/fat/Scripts"
        echo ""
        curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location -o "/media/fat/Scripts/update_bios-getter.sh" https://github.com/MAME-GETTER/MiSTer_BIOS_SCRIPTS/raw/master/update_bios-getter.sh
        echo
fi


SYSTEMS_WITH_BIOS=( \
    AO486 \
    Astrocade \
    AtariLynx \
    GAMEBOY \
    GBA \
    Intellivision \
    Interact \
    MegaCD \
    NeoGeo \
    NES \
    SNES \
    TGFX16 \
    WonderSwan \
)

GAMESDIR_FOLDERS=( \
    /media/fat \
    /media/usb0 \
    /media/usb1 \
    /media/usb2 \
    /media/usb3 \
    /media/usb4 \
    /media/usb5 \
    /media/usb0/games \
    /media/usb1/games \
    /media/usb2/games \
    /media/usb3/games \
    /media/usb4/games \
    /media/usb5/games \
    /media/fat/cifs \
    /media/fat/cifs/games \
    /media/fat/games \
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

declare -A INTELLIVISION_BIOS=( \
    ["boot0.rom"]="Executive ROM, The (1978)(Mattel).bin" \
    ["boot1.rom"]="GROM, The (1978)(General Instruments).bin" \
    ["boot2.rom"]="IntelliVoice BIOS (1981)(Mattel).bin" \
    ["boot3.rom"]="Entertainment Computer System's EXEC-BASIC ROM, The (1978)(Mattel).bin" \
)

declare -A WONDERSWAN_BIOS=( \
    ["boot.rom"]="boot.rom" \
    ["boot1.rom"]="boot1.rom" \
)

ITERATE_SYSTEMS()
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
            ao486)
                GETTER_DO INSTALL_AO486 "${SYSTEM}"
                ;;

            astrocade)
                GETTER_DO INSTALL_SINGLE_ROM "${SYSTEM}" 'boot.rom' \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/Astrocade.zip' \
                "Bally Professional Arcade, Astrocade '3159' BIOS (1978)(Bally Mfg. Corp.).bin"
                ;;

            atarilynx)
                GETTER_DO INSTALL_SINGLE_ROM "${SYSTEM}" 'boot.rom' \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/AtariLynx.zip' \
                'boot.rom'
                ;;

            gameboy)
                GETTER_DO INSTALL_SINGLE_ROM "${SYSTEM}" 'boot1.rom' \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/Gameboy.zip' \
                'GBC_boot_ROM.gb'
                ;;

            gba)
                GETTER_DO INSTALL_SINGLE_ROM "${SYSTEM}" 'boot.rom' \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/GBA.zip' \
                'gba_bios.bin'
                ;;

            intellivision)
                GETTER_DO INSTALL_MULTI_ROM_FROM_SINGLE_ZIP "${SYSTEM}" \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/Intellivision.zip' \
                INTELLIVISION_BIOS
                ;;

            interact)
                GETTER_DO INSTALL_SINGLE_ROM "${SYSTEM}" 'boot.rom' \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/Interact.zip' \
                'Interact_ROM.bin'
                ;;

            megacd)
                GETTER_DO INSTALL_MEGACD "${SYSTEM}"
                ;;

            neogeo)
                GETTER_DO INSTALL_NEOGEO "${SYSTEM}"
                ;;

            nes)
                GETTER_DO INSTALL_SINGLE_ROM "${SYSTEM}" 'boot0.rom' \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/NES.zip' \
                'fds-bios.rom'
                ;;

            snes)
                GETTER_DO INSTALL_SINGLE_ROM "${SYSTEM}" 'bsx_bios.rom' \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/SNES.zip' \
                'BS-X BIOS (English) [No DRM] [2016 v1.3].sfc'
                ;;

            tgfx16)
                local GAMESDIR_CD_FOLDER_NAME="TGFX16-CD"
                GET_SYSTEM_FOLDER "${GAMESDIR_CD_FOLDER_NAME}"
                if [[ "${GET_SYSTEM_FOLDER_RESULT}" == "" ]] ; then
                    GET_SYSTEM_FOLDER "${SYSTEM}"
                    if [[ "${GET_SYSTEM_FOLDER_RESULT}" != "" ]] ; then
                        mkdir -p "${GET_SYSTEM_FOLDER_GAMESDIR}/${GAMESDIR_CD_FOLDER_NAME}"
                    fi
                fi
                if [ -d "${GET_SYSTEM_FOLDER_GAMESDIR}/${GAMESDIR_CD_FOLDER_NAME}" ] ; then
                    GETTER_DO INSTALL_SINGLE_ROM "${GAMESDIR_CD_FOLDER_NAME}" 'cd_bios.rom' \
                    'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/TurboGrafx16.zip' \
                    'Super CD 3.1.pce'
                fi
                ;;

            wonderswan)
                GETTER_DO INSTALL_MULTI_ROM_FROM_SINGLE_ZIP "${SYSTEM}" \
                'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/WonderSwan.zip' \
                WONDERSWAN_BIOS
                ;;

        esac

    done 
}

GETTER_DO()
{
    local CALLBACK="${1}"
    local SYSTEM="${2}"

    shift
    shift

    GET_SYSTEM_FOLDER "${SYSTEM}"
    local SYSTEM_FOLDER="${GET_SYSTEM_FOLDER_RESULT}"
    local GAMESDIR="${GET_SYSTEM_FOLDER_GAMESDIR}"

    if [[ "${SYSTEM_FOLDER}" == "" ]]
        then
            mkdir -p "${GAMESDIR}/${SYSTEM}"
            GET_SYSTEM_FOLDER "${SYSTEM}"
            SYSTEM_FOLDER="${GET_SYSTEM_FOLDER_RESULT}"
            GAMESDIR="${GET_SYSTEM_FOLDER_GAMESDIR}"
    fi

    if [[ "${SYSTEM_FOLDER}" != "" ]]
        then
            echo ""
            echo "STARTING BIOS RETRIVAL FOR: ${SYSTEM_FOLDER}" 
            echo ""
            ${CALLBACK} "${SYSTEM_FOLDER}" "${GAMESDIR}" "${@}"
            echo ""
    else
            echo "Please create a "${GAMESDIR}/${SYSTEM}" directory" >> /tmp/dir.errors
    fi	
            echo ""
            echo "##################################################################"
}

INSTALL_SINGLE_ROM()
{
    local SYSTEM_FOLDER="${1}"
    local GAMESDIR="${2}"
    local TARGET_ROM_NAME="${3}"
    local SOURCE_FILE_URL="${4}"
    local SOURCE_UNZIPPED_ROM_NAME="${5}"

    local GAMESDIR_TARGET_FILE="${GAMESDIR}/${SYSTEM_FOLDER}/${TARGET_ROM_NAME}"

    if [ -e "${GAMESDIR_TARGET_FILE}" ]
        then
            echo "${NOTHING_TO_BE_DONE_MSG}"
            echo "Skipped '${GAMESDIR_TARGET_FILE}' because already exists." >> /tmp/bios.info
        else
            if [[ "${SOURCE_FILE_URL^^}" =~ \.ZIP$ ]] ; then
                FETCH_FILE_ZIP "${SYSTEM_FOLDER}" "${SOURCE_FILE_URL}" "${SOURCE_UNZIPPED_ROM_NAME}"
            else
                FETCH_FILE_NORMAL "${SYSTEM_FOLDER}" "${SOURCE_FILE_URL}"
            fi
            echo
            COPY_BIOS_TO_GAMESDIR "${FETCH_FILE_RESULT_BIOS_SOURCE_FILE}" "${GAMESDIR_TARGET_FILE}" "${SYSTEM_FOLDER}"
    fi
}

INSTALL_MULTI_ROM_FROM_SINGLE_ZIP()
{
    local SYSTEM_FOLDER="${1}"
    local GAMESDIR="${2}"
    local SOURCE_FILE_URL="${3}"
    declare -n ARRAY="${4}"

    if [[ "${SYSTEM_FOLDER}" == "Intellivision" ]] ; then
        mkdir -p "${GAMESDIR}/${SYSTEM_FOLDER}"
    fi

    local NOTHING_DONE_COUNTER=0

    for rom in ${!ARRAY[@]}
    do
        local FILE="${ARRAY[${rom}]}"

        local INSTALL=$(INSTALL_SINGLE_ROM "${SYSTEM_FOLDER}" "${GAMESDIR}" "${rom}" "${SOURCE_FILE_URL}" "${FILE}")
        if [[ "${INSTALL}" != "${NOTHING_TO_BE_DONE_MSG}" ]] ; then
            echo "${INSTALL}"
        else
            NOTHING_DONE_COUNTER=$((NOTHING_DONE_COUNTER + 1))
        fi
    done

    if [[ "${NOTHING_DONE_COUNTER}" == "${#ARRAY[@]}" ]] ; then
        echo "${NOTHING_TO_BE_DONE_MSG}"
    fi
}

INSTALL_AO486()
{
    local SYSTEM_FOLDER="${1}"
    local GAMESDIR="${2}"

    local INSTALL_1=$(INSTALL_SINGLE_ROM "${SYSTEM_FOLDER}" "${GAMESDIR}" "boot0.rom" "https://raw.githubusercontent.com/MiSTer-devel/ao486_MiSTer/master/releases/bios/boot0.rom" "")
    if [[ "${INSTALL_1}" != "${NOTHING_TO_BE_DONE_MSG}" ]]; then
        echo "${INSTALL_1}"
    fi

    echo
    local INSTALL_2=$(INSTALL_SINGLE_ROM "${SYSTEM_FOLDER}" "${GAMESDIR}" "boot1.rom" "https://raw.githubusercontent.com/MiSTer-devel/ao486_MiSTer/master/releases/bios/boot1.rom" "")
    if [[ "${INSTALL_2}" != "${NOTHING_TO_BE_DONE_MSG}" ]]; then
        echo "${INSTALL_2}"
    fi

    if [[ "${INSTALL_1}" == "${NOTHING_TO_BE_DONE_MSG}" ]] && [[ "${INSTALL_2}" == "${NOTHING_TO_BE_DONE_MSG}" ]] ; then
        echo "${NOTHING_TO_BE_DONE_MSG}"
    fi
}

INSTALL_MEGACD()
{
    local SYSTEM_FOLDER="${1}"
    local GAMESDIR="${2}"

    local BOOT_ROM='boot.rom'
    local ZIP_URL='https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/MegaCD.zip'
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
        local MESSAGE=$(INSTALL_SINGLE_ROM "${SYSTEM_FOLDER}" "${GAMESDIR}" "${BOOT_ROM}" "${ZIP_URL}" "${BIOS_ROM}")
        if [[ "${MESSAGE}" != "${NOTHING_TO_BE_DONE_MSG}" ]]; then
            echo "${MESSAGE}"
        fi
        COPY_MEGACD_REGION "${SYSTEM_FOLDER}" "${GAMESDIR}" "${BIOSDIR}/MegaCD/[BIOS] Mega-CD 2 (Japan) (v2.00C).md" "Japan"
        COPY_MEGACD_REGION "${SYSTEM_FOLDER}" "${GAMESDIR}" "${BIOSDIR}/MegaCD/[BIOS] Sega CD 2 (USA) (v2.00).md" "USA"
        COPY_MEGACD_REGION "${SYSTEM_FOLDER}" "${GAMESDIR}" "${BIOSDIR}/MegaCD/[BIOS] Mega-CD 2 (Europe) (v2.00).md" "Europe"
    fi
}

COPY_MEGACD_REGION()
{
    local SYSTEM_FOLDER="${1}"
    local GAMESDIR="${2}"
    local BIOS_SOURCE="${3}"
    local REGION="${4}"

    local GAMES_TARGET="${GAMESDIR}/${SYSTEM_FOLDER}/${REGION}/cd_bios.rom"
    if [ -f "${GAMES_TARGET}" ] ; then
        echo "Skipped '$GAMES_TARGET' because already exists." >> /tmp/bios.info
    elif [ -f "${BIOS_SOURCE}" ] ; then
        mkdir -p "${GAMESDIR}/${SYSTEM_FOLDER}/${REGION}"
        COPY_BIOS_TO_GAMESDIR "${BIOS_SOURCE}" "${GAMES_TARGET}" "${SYSTEM_FOLDER}"
    fi
}

INSTALL_NEOGEO()
{
    local SYSTEM_FOLDER="${1}"
    local GAMESDIR="${2}"

    rm /tmp/neogeo.bios.file 2> /dev/null
    for NEO_BIOS_REGEX in ${NEOGEO_BIOS[@]}
    do
        find "${GAMESDIR}/${SYSTEM_FOLDER}/" -maxdepth 1 -type f -regextype grep -regex "${GAMESDIR}/${SYSTEM_FOLDER}/${NEO_BIOS_REGEX}" | \
        while read NEO_BIOS_PATH
        do
            echo "  ${NEO_BIOS_PATH}" >> /tmp/neogeo.bios.file
        done
    done

    if [ -e /tmp/neogeo.bios.file ]
        then
            echo "${NOTHING_TO_BE_DONE_MSG}"
            echo "Skipped 'NeoGeo' because following files already exists:" >> /tmp/bios.info
            cat /tmp/neogeo.bios.file >> /tmp/bios.info
        else
            if [ ! -f "${BIOSDIR}/NeoGeo/uni-bios.rom" ]
                then
                    DOWNLOAD_ZIP "http://unibios.free.fr/download/uni-bios-40.zip" "${BIOSDIR}/uni-bios-40.zip" "${BIOSDIR}/NeoGeo"
                    echo
            fi

            INSTALL_SINGLE_ROM "${SYSTEM_FOLDER}" "${GAMESDIR}" '000-lo.lo' 'https://archive.org/download/mister-console-bios-pack_theypsilon/MiSTer_Console_BIOS_PACK.zip/NeoGeo.zip' '000-lo.lo'

            COPY_BIOS_TO_GAMESDIR "${BIOSDIR}/NeoGeo/sfix.sfix" "${GAMESDIR}/${SYSTEM_FOLDER}/sfix.sfix" "${SYSTEM_FOLDER}"
            COPY_BIOS_TO_GAMESDIR "${BIOSDIR}/NeoGeo/uni-bios.rom" "${GAMESDIR}/${SYSTEM_FOLDER}/uni-bios.rom" "${SYSTEM_FOLDER}"
    fi
    echo
}

FETCH_FILE_RESULT_BIOS_SOURCE_FILE=
FETCH_FILE_NORMAL()
{
    local SYSTEM_FOLDER="${1}"
    local SOURCE_FILE_URL="${2}"

    local SOURCE_FILE_BASENAME="$(basename ${SOURCE_FILE_URL})"
    local BIOS_SOURCE_FILE="${BIOSDIR}/${SYSTEM_FOLDER}/${SOURCE_FILE_BASENAME}"

    if [ ! -f "${BIOS_SOURCE_FILE}" ] ; then
        mkdir -vp "$(dirname ${BIOS_SOURCE_FILE})"
        DOWNLOAD_FILE "${SOURCE_FILE_URL}" "${BIOS_SOURCE_FILE}"
    fi
    FETCH_FILE_RESULT_BIOS_SOURCE_FILE="${BIOS_SOURCE_FILE}"
}
FETCH_FILE_ZIP()
{
    local SYSTEM_FOLDER="${1}"
    local SOURCE_FILE_URL="${2}"
    local SOURCE_UNZIPPED_ROM_NAME="${3}"

    local SOURCE_FILE_BASENAME=$(basename "${SOURCE_FILE_URL}")
    local BIOS_SOURCE_FILE="${BIOSDIR}/${SOURCE_FILE_BASENAME%.*}/${SOURCE_UNZIPPED_ROM_NAME}"
    local CURL_OUTPUT_PATH="${BIOSDIR}/${SOURCE_FILE_BASENAME}"
    local BIOS_SOURCE_DIR=$(dirname "${BIOS_SOURCE_FILE}")

    if [ ! -f "${BIOS_SOURCE_FILE}" ] ; then
        mkdir -vp "${BIOS_SOURCE_DIR}"
        DOWNLOAD_ZIP "${SOURCE_FILE_URL}" "${CURL_OUTPUT_PATH}" "${BIOS_SOURCE_DIR}"
    fi
    FETCH_FILE_RESULT_BIOS_SOURCE_FILE="${BIOS_SOURCE_FILE}"
}

DOWNLOAD_ZIP()
{
    local SOURCE_FILE_URL="${1}"
    local CURL_OUTPUT_PATH="${2}"
    local BIOS_SOURCE_DIR="${3}"
    DOWNLOAD_FILE "${SOURCE_FILE_URL}" "${CURL_OUTPUT_PATH}"
    unzip -o -j "${CURL_OUTPUT_PATH}" -d "${BIOS_SOURCE_DIR}/"
    rm "${CURL_OUTPUT_PATH}" 2> /dev/null
}

DOWNLOAD_FILE()
{
    local SOURCE_FILE_URL="${1}"
    local CURL_OUTPUT_PATH="${2}"
    echo "Downloading ${SOURCE_FILE_URL}"
    curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -s --fail --location -o "${CURL_OUTPUT_PATH}" "${SOURCE_FILE_URL}" > /dev/null
}


GET_SYSTEM_FOLDER_GAMESDIR=
GET_SYSTEM_FOLDER_RESULT=
GET_SYSTEM_FOLDER()
{
    GET_SYSTEM_FOLDER_GAMESDIR="/media/fat/games"
    GET_SYSTEM_FOLDER_RESULT=
    local SYSTEM="${1}"
    for folder in ${GAMESDIR_FOLDERS[@]}
    do
        local RESULT=$(find "${folder}" -maxdepth 1 -type d -iname "${SYSTEM}" -printf "%P\n" -quit 2> /dev/null)
        if [[ "${RESULT}" != "" ]] ; then
            GET_SYSTEM_FOLDER_GAMESDIR="${folder}"
            GET_SYSTEM_FOLDER_RESULT="${RESULT}"
            break
        fi
    done
}

COPY_BIOS_TO_GAMESDIR()
{
    local BIOS_SOURCE="${1}"
    local GAMES_TARGET="${2}"
    local SYSTEM="${3}"

    cp -vn "$BIOS_SOURCE" "$GAMES_TARGET"
    [ $? -ne 0 ] && echo "ERROR: BIOS was not able to be set for $SYSTEM" >> /tmp/bios.errors
}

############### START ################

#clean up errors file if it exist
rm -v /tmp/bios.errors 2> /dev/null
rm -v /tmp/bios.info 2> /dev/null
rm -v /tmp/dir.errors 2> /dev/null

mkdir -p "${BIOSDIR}"

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

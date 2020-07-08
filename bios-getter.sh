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
NOTHING_TO_BE_DONE_MSG="Nothing to be done."

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

ASTROCADE_BIOS_SHA1_HASHES=( \
    "D84341FEEC1A0A0E8AA6151B649BC3CF6EF69FBF" `#Bally Computer System 'White' BIOS (1977)(Bally Mfg. Corp.).bin` \
    "6B2BEF5D970E54ED204549F58BA6D197A8BFD3CC" `#Bally Home Library Computer '3164' BIOS (1977)(Bally Mfg. Corp.).bin` \
    "B902C941997C9D150A560435BF517C6A28137ECC" `#Bally Professional Arcade, Astrocade '3159' BIOS (1978)(Bally Mfg. Corp.).bin` \
)

GAMEBOY_BIOS_SHA1_HASHES=( \
    "4ED31EC6B0B175BB109C0EB5FD3D193DA823339F" `#GB_boot_ROM.gb` \
    "1293D68BF9643BC4F36954C1E80E38F39864528D" `#GBC_boot_ROM.gb` \
)

GBA_BIOS_SHA1_HASHES=( \
    "AA98A2AD32B86106340665D1222D7D973A1361C7" `#[BIOS] Game Boy Advance (Japan) (Debug Version).gba` \
    "300C20DF6731A33952DED8C436F7F186D25D3492" `#gba_bios.bin` \
)

MEGACD_BIOS_SHA1_HASHES=(
    "7063192ae9f6b696c5b81bc8f0a9fe6f0c400e58" `#[BIOS] Mega-CD 2 (Europe) (v2.00).md` \
    "f5f60f03501908962446ee02fc27d98694dd157d" `#[BIOS] Mega-CD 2 (Europe) (v2.00W).md` \
    "d203cfe22c03ae479dd8ca33840cf8d9776eb3ff" `#[BIOS] Mega-CD 2 (Japan) (v2.00C).md` \
    "e4193c6ae44c3cea002707d2a88f1fbcced664de" `#[BIOS] Mega-CD (Asia) (v1.00S).md` \
    "f891e0ea651e2232af0c5c4cb46a0cae2ee8f356" `#[BIOS] Mega-CD (Europe) (v1.00).md` \
    "0d5485e67c3f033c41d677cc9936afd6ad618d5f" `#[BIOS] Mega-CD (Japan) (1.00l).md` \
    "230ebfc49dc9e15422089474bcc9fa040f2c57eb" `#[BIOS] Mega-CD (Japan) (1.00S).md` \
    "6a40a5cec00c3b49a4fd013505c5580baa733a29" `#[BIOS] Mega-CD (Japan) (v1.00G).md` \
    "9e1495e62b000e1e1c868c0f3b6982e1abbb8a94" `#[BIOS] Mega-CD (Japan) (v1.00O).md` \
    "2bd871e53960bc0202c948525c02584399bc2478" `#[BIOS] Mega-CD (Japan) (v1.01).md` \
    "5a8c4b91d3034c1448aac4b5dc9a6484fce51636" `#[BIOS] Sega CD 2 (USA) (v2.00).md` \
    "5adb6c3af218c60868e6b723ec47e36bbdf5e6f0" `#[BIOS] Sega CD 2 (USA) (v2.00W).md` \
    "328a3228c29fba244b9db2055adc1ec4f7a87e6b" `#[BIOS] Sega CD 2 (USA) (v2.11X).md` \
    "2f397218764502f184f23055055bc5728c71f259" `#[BIOS] Sega CD 68K (Unknown) (Unl).md` \
    "c5c24e6439a148b7f4c7ea269d09b7a23fe25075" `#[BIOS] Sega CD (USA) (v1.00).md` \
    "f4f315adcef9b8feb0364c21ab7f0eaf5457f3ed" `#[BIOS] Sega CD (USA) (v1.10).md` \
    "98bbe341fd60de4e45fc4bed0b47aaabf8707322" `#[BIOS] Sega CD (USA) (v1.10).md` \
    "98bbe341fd60de4e45fc4bed0b47aaabf8707322" `#EU Mega-CD 1 (Region Free) 921027 l_oliveira.bin` \
    "27868fb5a8587b4212c96ed36a84a0a8c48569b1" `#EU Mega-CD 2 (Region Free) 930330 l_oliveira.bin` \
    "d827777ff3a20525bf4b9c103c48d2704adfce99" `#EU Mega-CD 2 (Region Free) 930601 l_oliveira.bin` \
    "19448fb968629ce3b307f0896471188f99db717c" `#JP Mega-CD 1 PAL (Region Free) 911228 l_oliveira.bin` \
    "576a09bcfb78cb209d9cccf8573abb2989aafe43" `#JP Mega-CD 1 (Region Free) 911217 l_oliveira.bin` \
    "d620b4cf258319b4e8de28671c71afe003d39bb1" `#JP Mega-CD 1 (Region Free) 911228 l_oliveira.bin` \
    "d48a05075ef0f9d146218c8bec7759bd97426bf7" `#JP Mega-CD 2 (Region Free) 921222 l_oliveira.bin` \
    "219d284dcf63ce366a4dc6d1ff767a0d2eea283d" `#MPR-15768-T.bin` \
    "0a1910f3f7d9ab284cd0480430322e5edd65e79d" `#US Sega CD 1 (Region Free) 921011 l_oliveira.bin` \
    "12ecb008f8efebecc9c14f8a6023b4ae12a5e937" `#US Sega CD 2 (Region Free) 930314 l_oliveira.bin` \
    "9eed922bec1b9ff2b611dacf484d710b732bea5e" `#US Sega CD 2 (Region Free) 930601 l_oliveira.bin` \
    "c8d4290ff3199bda43acd84ed5067565a8e7666d" `#US Sega CDX (Region Free) 930907 l_oliveira.bin` \
    "b3f32e409bd5508c89ed8be33d41a58d791d0e5d" `#WONDERMEGA-G303.BIN` \
)

NEOGEO_BIOS_SHA1_HASHES=( \
    "5992277debadeb64d1c1c64b0a92d9293eaf7e4a" `#000-lo.lo` \
    "neo-epo.sp1-AES_BIOS" `#neo-epo.sp1-AES_BIOS` \
    "fd4a618cdcdbf849374f0a50dd8efe9dbab706c3" `#sfix.sfix` \
    "4f5ed7105b7128794654ce82b51723e16e389543" `#sp-s2.sp1-MVS_BIOS` \
    "938a0bda7d9a357240718c2cec319878d36b8f72" `#uni-bios.rom` \
)

NES_BIOS_SHA1_HASHES=( \
    "AF5AF53F66982E749643FDF8B2ACBB7D4D3ED229" `#fds-bios (Beta).rom` \
    "E4E41472C454F928E53EB10E0509BF7D1146ECC1" `#fds-bios (Twin Famicom).rom` \
    "57FE1BDEE955BB48D357E463CCBF129496930B62" `#fds-bios.rom` \
)

TURBOGRAFX16_BIOS_SHA1_HASHES=( \
    "ae1275729503851473bfcb1b4a716a70b8b20748" `#[BIOS] CD-ROM System (Japan) (v1.0)_autoboot.pce` \
    "d1ac6d05e238f0f217248005117f427748a29512" `#[BIOS] CD-ROM System (Japan) (v2.0)_autoboot.pce` \
    "64e98ff346926a9eea0755f52e9b32fa50a500b6" `#[BIOS] CD-ROM System (Japan) (v2.1)_autoboot.pce` \
    "a93b99e74945e38b2d74c4dc43bcd221ec1ec705" `#[BIOS] Super CD-ROM System (Japan) (v3.0)_autoboot.pce` \
    "1837bf25bf4a8e3ef4ec6af36e2e1b8a0e4be9a2" `#[BIOS] TurboGrafx CD Super System Card (USA) (v3.0)_autoboot.pce` \
    "1dbb9b750d030b658db20e0b434883a8c82cefa5" `#[BIOS] TurboGrafx CD System Card (USA) (v2.0)_autoboot.pce` \
    "88da02e2503f7c32810f5d93a34849d470742b6d" `#CD-ROM System 2.1.pce` \
    "a39a66da7de6ba94ab84d04eef7afeec7d4ee66a" `#CD-ROM System v1.0.pce` \
    "f92ea593c8a935f58f8e1c3b2fc730951ec4fa71" `#CD-ROM System v2.0.pce` \
    "79f5ff55dd10187c7fd7b8daab0b3ffbd1f56a2c" `#Super CD 3.0.pce` \
    "d02611d99921986147c753df14c7349b31d71950" `#TGX CD Super System Card 3.0.pce` \
    "2bea3dac98f84b2f2f469fa77ea720b8770d598d" `#TGX CD System Card 2.0.pce` \
)

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

# takes in hashlist and file to hash
# returns sha1 if matched and false if not
ISSHA1VALID() {
    local hashlist=("$1")
    local script_sha1=($(sha1sum $2))
    local matched="false"

    for i in ${hashlist[@]} ; do
        local file_sha1=$(echo "${i}" | awk '{print tolower($0)}')
        if [ "$script_sha1" = "$file_sha1" ]; then
        local matched=$file_sha1
        break
        fi
    done
    echo $matched

}

GETTER ()

{
    local SYSTEM="${1}"
    local BOOT_ROM="${2}"
    local ZIP_URL="${3}"
    local BIOS_ROM="${4}"
    local HASH_LIST=() # default to an emptry array so we can pass it along easier
    if [  "$#" -gt "4" ]; then # only try to get the arg5 value if there is more than 4 args
        local HASH_LIST="${5}" 
    fi

    local SYSTEM_FOLDER=$(GET_SYSTEM_FOLDER "${SYSTEM}")
    
    if [[ "${SYSTEM_FOLDER}" != "" ]]
        then
            echo ""
            echo "STARTING BIOS RETRIEVAL FOR: $SYSTEM_FOLDER" 
            echo ""
            GETTER_INTERNAL "${SYSTEM_FOLDER}" "${BOOT_ROM}" "${ZIP_URL}" "${BIOS_ROM}" "$(echo ${HASH_LIST[@]})"
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
    local HASH_LIST=() # default to an emptry array so we can pass it along easier
    if [  "$#" -gt "4" ]; then # only try to get the arg5 value if there is more than 4 args
        local HASH_LIST="${5}" 
    fi

    local GAMES_TARGET="$GAMESDIR/$SYSTEM_FOLDER/$BOOT_ROM"
    if [ -e "$GAMES_TARGET" ]
        then
            echo "${NOTHING_TO_BE_DONE_MSG}"
            echo "Skipped '$GAMES_TARGET' because already exists." >> /tmp/bios.info
            if [ -n "$HASH_LIST" ]; then #only check hash if passed for system. this is set to empy array in GETTER if not passed
                local ISHASHVALID=$(ISSHA1VALID "$(echo ${HASH_LIST[@]})" "$GAMES_TARGET")
                if [ "$ISHASHVALID" = "false" ]; then
                    echo "The bios file $GAMES_TARGET doesn't match our known checksums, If you would like this script to update it please remove it and rerun this script else, no action is needed" >> /tmp/bios.info
                fi
            fi

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
                "Bally Professional Arcade, Astrocade '3159' BIOS (1978)(Bally Mfg. Corp.).bin" \
                "$(echo ${ASTROCADE_BIOS_SHA1_HASHES[@]})"
                ;;

            gameboy)
                GETTER "${SYSTEM}" 'boot1.rom' \
                'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/Gameboy.zip' \
                'GBC_boot_ROM.gb' \
                "$(echo ${GAMEBOY_BIOS_SHA1_HASHES[@]})"
                ;;

            gba)
                GETTER "${SYSTEM}" 'boot.rom' \
                'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/GBA.zip' \
                'gba_bios.bin' \
                "$(echo ${GBA_BIOS_SHA1_HASHES[@]})"
                ;;

            megacd)
                local SYSTEM_FOLDER=$(GET_SYSTEM_FOLDER "${SYSTEM}")
                if [[ "${SYSTEM_FOLDER}" != "" ]]
                    then
                        echo ""
                        echo "STARTING BIOS RETRIEVAL FOR: $SYSTEM_FOLDER"
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
                                local ISHASHVALID=$(ISSHA1VALID "$(echo ${MEGACD_BIOS_SHA1_HASHES[@]})" "${bios}")
                                if [ "$ISHASHVALID" = "false" ]; then
                                    echo "The bios file ${bios} doesn't match our known checksums, If you would like this script to update it please remove it and rerun this script else, no action is needed" >> /tmp/bios.info
                                fi
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
                                local ISHASHVALID=$(ISSHA1VALID "$(echo ${NEOGEO_BIOS_SHA1_HASHES[@]})" "${NEO_BIOS_PATH}")
                                if [ "$ISHASHVALID" = "false" ]; then
                                    echo "  The bios file ${NEO_BIOS_PATH} doesn't match our known checksums, If you would like this script to update it please remove it and rerun this script else, no action is needed" >> /tmp/neogeo.bios.file
                                fi
                            done
                        done

                                echo ""
                                echo "STARTING BIOS RETRIEVAL FOR: NEOGEO"
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
                'fds-bios.rom' \
                "$(echo ${NES_BIOS_SHA1_HASHES[@]})"
                ;;

            turbografx16)
                mkdir -p "${GAMESDIR}/TGFX16-CD"
                GETTER 'TGFX16-CD' 'cd_bios.rom' \
                'https://archive.org/download/mi-ster-console-bios-pack/MiSTer_Console_BIOS_PACK.zip/TurboGrafx16.zip' \
                'Super CD 3.0.pce' \
                "$(echo ${TURBOGRAFX16_BIOS_SHA1_HASHES[@]})"
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

# MiSTer_BIOS_Scripts 
Simple scripts to automate downloading BIOS files for MiSTer console cores

Instructions

Download the update_bios-getter.sh to the Scripts directory and run:

update_bios-getter.sh

These scripts DO NOT download any cores. 

Q:Will this script over write files I already have?

A: NO, This script will not clober files you already have. You need to manaully remove any files you have if you want to download new files BIOS files for the core.

Q: Where are the Downloaded BIOS files located?

A: This script downloads all bios files to /media/fat/BIOS.

Q: Can I set a custom BIOS directory location?

A: Yes, in the update_bios-getter.ini: BIOSDIR=/path/to/your/location

#Q: Can I set this to work with usb drives?

#A: yes, in the update_bios-getter.ini: GAMESDIR=/media/usb0/games


You should back up your bios files before running this script.

USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY KILL BABY SEALS.

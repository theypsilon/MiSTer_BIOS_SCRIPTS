# MiSTer_BIOS_Scripts
Simple scripts to automate downloading BIOS files for MiSTer console cores based on your rbf files.

Instructions

Download the update_console-bios-getter.sh to the Scripts directory and run:

update_console-bios-getter.sh

These scripts look at what RBFconsole core files you have and downloads the bios needed for them.

These scripts DO NOT download any cores. 

Q:Will this script over write files I already have?

A: NO, This script will not clober files you already have. You need to manaully remove any files you have if you want to download new files BIOS files for the core.

Q: Where are the Downloaded BIOS files located?

A: This script downloads all bios files to /media/fat/BIOS. Symlinks are used in the consoles games directory to link back to the BIOS directory.

Q: Can I set a custom BIOS directory location.

A: Yes, in the update_console-bios-getter.ini: BIOS_DIR=/path/to/your/location

#Q: Can I set this to work with usb drives?

#A: yes,in the update_console-bios-getter.ini: COREPARTITON=/media/usb0


You should back up your bios files before running this script.

USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY KILL BABY SEALS.

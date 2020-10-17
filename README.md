# MiSTer_BIOS_Scripts 
Simple scripts to automate downloading BIOS files for MiSTer console cores.

## Instructions

Download the <a id="raw-url" href="https://raw.githubusercontent.com/MAME-GETTER/MiSTer_BIOS_SCRIPTS/master/update_bios-getter.sh" download target="_blank">update_bios-getter.sh</a> to the Scripts directory and run:

    update_bios-getter.sh

These scripts look at what RBFconsole core files you have and downloads the bios needed for them.

This script DOES NOT download any cores. 

### FAQ

**Q:** Will this script overwrite any files I already have?

**A:** NO. This script will not clobber any files you already have. You need to manually remove any BIOS files you have if you want to download new BIOS files for the core.

**Q:** Where are the Downloaded BIOS files located?

**A:** This script downloads all bios files to /media/fat/BIOS.

**Q:** Can I set a custom BIOS directory location?

**A:** Yes, in the update_bios-getter.ini: BIOSDIR=/path/to/your/location

**Q:** Can I set this to work with usb drives?

**A:** Yes, this script will automatically recognize all the directories the same way the MiSTer binary would do

The bios-getter will download many bios files to /media/fat/BIOS. However, we have chosen some sane defaults to be copied to the /games/<console> directory. These defaults are:
  
  Astrocade
  ```
  Bally Professional Arcade, Astrocade '3159' BIOS (1978)(Bally Mfg. Corp.).bin
  ```
  
  Gameboy
  ```
  GB_boot_ROM.gb
  ```

  GBA
  ```
  gba_bios.bin
  ```

  MegaCD    
  ```
  [BIOS] Mega-CD 2 (Japan) (v2.00C).md" "Japan"
  [BIOS] Sega CD 2 (USA) (v2.00).md" "USA"
  [BIOS] Mega-CD 2 (Europe) (v2.00).md" "Europe"
 ```
 
 NeoGeo     
 ```
 000-lo.lo
 sfix.sfix
 uni-bios-40
 ```
 
 NES
 ```
 fds-bios.rom
 ```
 
 TGFX16-CD
 ```
 Super CD 3.0.pce
 ```

**You should back up your bios files before running this script.**

USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTY AND MAY KILL BABY SEALS.

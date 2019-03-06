<a href="https://freeinfantry.com/">![Free Infantry](./.github/infantryonline.png)</a>


# Infantry Online: Game Zone Assets

> This repository will be used to keep active assets that may be rotated into active play, or to be used by developers in new projects. All new zone assets added by pull request should contain all files needed to simply dump into the server as-is and run without error.

**Need Help? Join our discord chat or review our open-source [game server repository](InfantryOnline/Infantry-Online-Server) for more information.**


![Discord](https://img.shields.io/discord/286700121217957888.svg?label=Discord&logo=Free%20Infantry&style=for-the-badge)

---

## Table of Contents

- [Understanding the Repository Structure](#repository-folder-structure)
- [Contributing](#contributing)
- [Support](#support)

---

## Repository Folder Structure

This repository has been organized in a way to make finding, and sharing (, and fixing) zones for the game easy to manage. All archived zones should be contained within their own folder and contain all files required by the zone's CFG file.

- **Complete Zones:**  
  Zone files, packaged in their own folder, with all required files and are fully compatible with the Free Infantry server. These are essentially "plug-and-play" zone archives.
- **Incompatible Zone Archives:**  
  These zone files, also packaged in their own folder, have various issues with the Free Infantry server. The goal is to get these working by (preferred) fixing the zone files, or (if not possible) making corrections to the Free Infantry server code to increase compatibility. This archive contains sub-folders to denote the type of error the zone archives are currently having. Once fixed, they can be moved to the **Complete Zones** folder.
- **Map Files:**  
  This folder contains original map files _with all physics still intact_ to aid in future development efforts.
- **Orphaned Archive Files:**  
  This folder contains files that no longer are associated with a zone. These files were kept to potentially aid in future development efforts.

**Folder Structure, Visualized:**
> _As errors are fixed the "Incompatible Zone Archives" can - eventually - be fully removed._

```
├───Complete Zones
│   └───[...]
├───Incompatible Zone Archives
│   ├───ArgumentException
│   │   └───[...]
│   ├───FormatException
│   │   └───[...]
│   ├───IndexOutOfRange
│   │   └───[...]
│   ├───KeyNotFoundException
│   │   └───[...]
│   ├───OutOfMemory
│   │   └───[...]
│   └───SilentClientCrash
│       └───[...]
├───Map Files
│   └───[...]
└───Orphaned Archive Files
    ├───blo
    ├───cfs
    ├───itm
    ├───lio
    ├───lua
    ├───lvb
    ├───lvl
    ├───nws
    ├───rpg
    ├───txt
    └───veh
```

If you are a map developer, or have archives that we are missing, please contribute to this effort of centralizing all files. To do so, please read over the **Contributing Guidelines** below.

---

## Contributing
> **NOTE:** Contributing to repositories on Github requires a Github account. It's free, quick, and easy.

There are a few ways available to contribute:

1. [Provide Updated Zone Information](#option-1-provide-updated-zone-information)
2. [Fix Incompatible Archives](#option-2-fix-currently-incompatible-zones)
3. [Supply Additional Zones](#option-3-provide-your-own-complete-zone-files)
   1. [From your own old game backups (if we don't already have it)](#from-old-file-backups)  
   2. [By developing your own and including all files required to run the zone](#new-creations-or-mashups)

---

### Option 1: Provide Updated Zone Information

All zones should have a `README.md` file in their containing folder. The purpose of this file is to provide Github with a way to describe the zone as you look at its contents, more importantly it provides both historic information (which we may have lost/forgotten over time) and information that can be used to configure the server for the zone.

The `README.md` has a strict and expected format to follow. It is using standard INI formatting rules, with one small exception - the value for the map image uses Markdown so that it will be displayed in Github when the zone folder's content is viewed. Many zones do not have ***any*** information within its `README.md` file - we can use your help to provide accurate (as possible) data to fill in the missing bits, as well as opening the files in the Map Editor and saving an image (as `map.jpg`) to add to the folder!

**README.md Format:**

```ini
; Leave any comments here. Useful comments such as which GameType Script(s)
; are required, and how they're to be used. If there are any outstanding
; issues with the zone. Anything else that may be useful to someone completely
; unfamiliar with the zone or its files.
; Comments should not exceed 90 characters in a single line.

; All variables (anything in []'s or before the = sign) MUST be left EXACTLY as below...
; The "map_image" value is to be left exactly as-is.
;   When a radar view of the map is provided, it should be named "map.png" and saved in
;   the zone's root folder.

; If a zone needs, or includes custom GameType scripts (not included in the server repo),
;   please indicate that through the "scripts_included" and "scripts_needed" variables
;   (using true or false).
;   DO NOT ENCLOSE true OR false IN QUOTATION MARKS

; If there are any custom scripts, please place them in a "ZoneScripts" folder inside
;   the zone's root folder, and provide the primary script name (if more than one)
;   in the "game_type" value.

[ZoneInfo]
name="Name of Zone (shown in the game's zonelist)"
description="Description of the zone (shown in the game's zonelist when zone is selected)"
zone_creators="Comma separated list of anyone involved in developing the ZONE"
map_creators="Comma separated list of anyone involved in ORIGINALLY developing the map"
map_name="Name given to the original map. This does not have to match the *.lvl filename*"
game_type="The type of game (i.e.: GameScript) for the server to be properly configured"
scripts_included=false
scripts_needed=false
map_image=![map](./map.png)
```

---

### Option 2: Fix Currently Incompatible Zones

The incompatible zones were provided from old backups of previously downloaded game assets. Unfortunately due to game client and server changes over the years, as well as poor naming schemes and game storage choices, things don't seem to work. The named folders for all zones in this category describe the various errors that may happen upon attempting to run the zone on the server. Fixing the particular error described may very well cause a different error that the server just couldn't reach previously. The goal here is to get all zones working (and if duplications were missed, to remove duplicate zones, taking care to note differences in vehicles, configurations, items, etc.).

There isn't much to say in tracking down errors here other than [running the game server yourself](InfantryOnline/Infantry-Online-Server), attempting to load the zone, and doing whatever you can with the CFG file, [the editors](https://freeinfantry.com/Editors.zip), and maybe even the server code (last resort) to allow a player to download, enter, and unspectate within a zone and not have it crash or throw errors.

Some zones may require their own custom GameType Script to function properly. If that is the case, please note it in the comments section of the `README.md`.

> **NOTE:** Inspecting the errors thrown that mention line numbers in the server's code will likely point you in the direction of which file, and possibly where within that file, a problem exists.

---

### Option 3: Provide Your Own Complete Zone Files

#### From Old File Backups

Most of the zones provided here are originally from old file backups. By inspecting the CFG files within your main Infantry program folder, it lists all of the files the particular zone requires in order to run on the server. By placing them all in their own named folder (named after the CFG file), you've just created a fully acceptable zone archive, with the exception of the additionally required `README.md` file for our own record-keeping purposes.

#### New Creations or Mashups

This option provides zone developers a single location to store and share their zone asset files during creation, testing, and its "vacation" from actual play. By adding your **working** files to this archive, you're insuring they are not lost to time, you continue the spirit of the open source nature of our game, and if ever built out - can be listed on a zone information website (this was the reasoning behind the INI format for the `README.md` files).

For a zone to be accepted into the archive, it must:

- Have all required files to run on the server
- Not throw any errors on the server when first added to the repository
- Provide a complete - and correctly formatted - `README.md` file in the root zone file folder
- Provide a `map.jpg` radar-view file of the map in the root zone file folder
- The zone file folder has the exact same name as the CFG file (preferably without spaces)

> *It is highly recommended to name your own zone files' filenames uniquely so that there is no chance of your files being overwritten on users' computers by the game client.*  
>  
> __Example__ *(developer\_gametype\_name.ext)*:  
> `Kaze_TDM_StarCraft.cfg`

---

## Support

For those willing to offer support in fixing the archives, the use of the Editors will be required. 

For stability of the editors, we highly recommend you use [Microsoft Virtual PC](https://www.microsoft.com/en-us/download/details.aspx?id=3702) along with [Windows XP Mode](https://www.microsoft.com/en-us/download/details.aspx%3Fid=8002). Other virtualization software (VMWare, Virtual Box) work as well. Alternatively, you can enable the included [Hyper-V under Windows 10 Pro](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v) and [run XP from that](https://superuser.com/questions/1288292/create-windows-xp-vm-on-windows-10). You'll also need a [copy of Windows XP](https://superuser.com/questions/1230652/get-official-windows-xp-virtual-machine-for-hyper-v).

If the virtual machine or Hyper-V route is too complicated, you may have some luck using compatibility mode on the editors with the following settings:

- Compatibility Mode: Windows XP SP2
- Reduced color mode: 16-bit (65536) color
- Disable fullscreen optimizations

Should you need further assistance, try our [Discord chat](https://discord.gg/2avPSyv).

- Editors at https://freeinfantry.com/Editors.zip
- Game at [https://freeinfantry.com/Infantry Online Setup.exe](http://freeinfantry.com/Infantry%20Online%20Setup.exe)

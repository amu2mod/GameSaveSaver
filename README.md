# GameSaveSaver

It's a script I've been using after losing my Elden Ring Nightreign save, which became corrupted after a PC crash. I started backing up my saves manually by locating the AppData folder and copying the files to another location. It worked, but repeating the process was tedious.

That's why I created this PowerShell script to automate the backup process. It currently only works on Windows.

## How to use it

The save locations must be manually configured in the script. Add your game's save path and the file extension(s) to the `$gameSavePaths` variable.

First, locate the save files for your game, then add them to the variable.

Example:

```powershell
$gameSavePaths = @{
    "EldenRingNightreign" = @{ Path = "C:\Users\Amu\AppData\Roaming\Nightreign\user_id"; Extensions = @("*.sl2") }
}
```

You can add as many games as you want.

For each entry, you can target:
- A specific file
- All files in a folder matching a specific extension (for example, `*.sl2`)

For FromSoftware games, the `.sl2` file is the actual save file. Backing up the `.bak` file is usually unnecessary and only uses additional disk space.

## Running the script

Once the paths are configured, run the script from a terminal using:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\the\script.ps1"
```

## Customizing options

### Backup drive

By default, backups are stored on the `C:` drive. You can change the destination drive or path by modifying the `$backupDrive` variable.

Example:

```powershell
$backupDrive = "C:\"
```
The `GameSaveBackups` folder will be created automatically in the selected location if it does not already exist.

### Backup rotation

The maximum number of backups to keep is controlled by the `$maxBackups` variable.

Example:

```powershell
$maxBackups = 5
```

The script will automatically rotate backups by keeping only the `X` most recent backups and removing older ones.

## Automation

For more convenience, the script can be automated using Windows Task Scheduler. You can configure it to run automatically at startup or on a schedule to keep your saves backed up regularly.

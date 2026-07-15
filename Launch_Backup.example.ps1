# PowerShell script to back up save files for multiple games to a separate partition

$gameSavePaths = @{
    "EldenRingNightreign" = @{ Path = "C:\Users\your_user_name\AppData\Roaming\Nightreign\your_user_id"; Extensions = @("*.sl2") }
    "EldenRing"         = @{ Path = "C:\Users\your_user_name\AppData\Roaming\EldenRing\your_user_id"; Extensions = @("*.sl2") }
    "Nioh2_SAVEDATA"             = @{ Path = "D:\your_user_name\Documents\KoeiTecmo\NIOH2\Savedata\your_user_id\SAVEDATA00"; Extensions = @("*.bin") }
	"Nioh2_SYSTEMDATA"             = @{ Path = "D:\your_user_name\Documents\KoeiTecmo\NIOH2\Savedata\your_user_id\SYSTEMSAVEDATA00"; Extensions = @("*.bin") }
	"Nioh3_SAVEDATA"             = @{ Path = "C:\Users\your_user_name\AppData\Local\KoeiTecmo\NIOH3\Savedata\your_user_id\SAVEDATA00"; Extensions = @("*.bin") }
	"Nioh3_SYSTEMDATA"             = @{ Path = "C:\Users\your_user_name\AppData\Local\KoeiTecmo\NIOH3\Savedata\your_user_id\SYSTEMSAVEDATA00"; Extensions = @("*.bin") }
	"DarkSoulsRemastered"         = @{ Path = "D:\your_user_name\Documents\NBGI\DARK SOULS REMASTERED\your_user_id"; Extensions = @("*.sl2") }
	"DarkSouls2"         = @{ Path = "C:\Users\your_user_name\AppData\Roaming\DarkSoulsII\your_user_id"; Extensions = @("*.sl2") }
	"DarkSouls3"         = @{ Path = "C:\Users\your_user_name\AppData\Roaming\DarkSoulsIII\your_user_id"; Extensions = @("*.sl2") }
	
    # Add more games here, e.g., "GameName" = @{ Path = "C:\Path\To\SaveFolder"; Extensions = @("*.sav", "*.bin") }
}

# Define backup settings
$backupDrive = "D:\"  # Replace with your SSD drive letter (e.g., "D:\")
$maxBackups = 5      # Maximum number of backups per game



#########################################
# Don't touch the code below
#########################################

# Create root backup folder if it doesn't exist
$rootBackupFolder = Join-Path -Path $backupDrive -ChildPath "GameSaveBackups"
if (-not (Test-Path -Path $rootBackupFolder)) {
    New-Item -Path $rootBackupFolder -ItemType Directory -ErrorAction SilentlyContinue
}

# Get current timestamp for backup folder names
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Loop through each game and perform backup
foreach ($game in $gameSavePaths.Keys) {
    $sourcePath = $gameSavePaths[$game].Path
    $extensions = $gameSavePaths[$game].Extensions
    $backupFolder = Join-Path -Path $rootBackupFolder -ChildPath $game
    $backupSubFolder = Join-Path -Path $backupFolder -ChildPath "Backup_$timestamp"

    # Create game-specific backup folder if it doesn't exist
    if (-not (Test-Path -Path $backupFolder)) {
        New-Item -Path $backupFolder -ItemType Directory -ErrorAction SilentlyContinue
    }

    # Create subfolder for this backup
    New-Item -Path $backupSubFolder -ItemType Directory -ErrorAction SilentlyContinue

    # Copy save files for each specified extension to the backup subfolder
    if (Test-Path -Path $sourcePath) {
        $filesCopied = $false
        foreach ($ext in $extensions) {
            $files = Copy-Item -Path "$sourcePath\$ext" -Destination $backupSubFolder -Force -ErrorAction SilentlyContinue -PassThru
            if ($files) { $filesCopied = $true }
        }
        if ($filesCopied) {
            Write-Host "Backed up $game saves ($($extensions -join ', ')) to $backupSubFolder"
        } else {
            Write-Host "Warning: No $($extensions -join ' or ') files found for $game in $sourcePath"
        }
    } else {
        Write-Host "Warning: Source path for $game ($sourcePath) not found. Skipping..."
    }

    # Manage backup limit (keep only the latest 10 per game)
    $backups = Get-ChildItem -Path $backupFolder -Directory -ErrorAction SilentlyContinue | Sort-Object CreationTime -Descending
    if ($null -ne $backups -and $backups.Count -gt $maxBackups) {
        $backups | Select-Object -Skip $maxBackups | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Safely display backup count
    $backupCount = if ($null -eq $backups) { 0 } else { $backups.Count }
    Write-Host "Total backups for $game`: $backupCount"
}

Write-Host "Backup process completed at $(Get-Date)."
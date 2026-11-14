# Resolve the current script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptVimKeyMapSubDir = Join-Path -Path $scriptDir -ChildPath "VimKeyMap"

# Resolve the current user's OneDrive directory
$oneDriveCandidates = @(
    $env:OneDriveConsumer
    $env:OneDrive
    (Join-Path -Path $env:USERPROFILE -ChildPath "OneDrive")
) |
    Where-Object {
        $_ -and (Test-Path -LiteralPath $_ -PathType Container)
    } |
    Select-Object -Unique

$oneDriveRoot = $oneDriveCandidates | Select-Object -First 1

if (-not $oneDriveRoot) {
    throw "Unable to locate the current user's OneDrive directory."
}

# Check localized OneDrive application folders in priority order.
# Stop immediately after finding the first valid remotely-save directory.
$appFolderNames = @(
    "應用程式"
    "Apps"
    "Applications"
)

$remotelySavePath = $null

foreach ($appFolderName in $appFolderNames) {
    $candidatePath = Join-Path `
        -Path $oneDriveRoot `
        -ChildPath "$appFolderName\remotely-save"

    Write-Host "Checking: $candidatePath"

    if (Test-Path -LiteralPath $candidatePath -PathType Container) {
        $remotelySavePath = $candidatePath

        Write-Host "Found remotely-save directory: $remotelySavePath"

        break
    }
}

if (-not $remotelySavePath) {
    $checkedPaths = $appFolderNames |
        ForEach-Object {
            Join-Path `
                -Path $oneDriveRoot `
                -ChildPath "$_\remotely-save"
        }

    throw (
        "Unable to locate the remotely-save directory. Checked paths:`n" +
        ($checkedPaths -join "`n")
    )
}

$obsidianVaultPath = Join-Path `
    -Path $remotelySavePath `
    -ChildPath "Obsidian Vault"

Write-Host ""
Write-Host "OneDrive directory:       $oneDriveRoot"
Write-Host "Remotely Save directory:  $remotelySavePath"
Write-Host "Obsidian Vault directory: $obsidianVaultPath"
Write-Host "------------------------------"

# Define target paths and corresponding source files/directories
$paths = [ordered]@{
    $obsidianVaultPath = ".obsidian.vimrc"

    [System.IO.Path]::Combine(
        [Environment]::GetFolderPath(
            [Environment+SpecialFolder]::LocalApplicationData
        ),
        "nvim"
    ) = "nvim/"

    [System.IO.Path]::Combine(
        [Environment]::GetFolderPath(
            [Environment+SpecialFolder]::UserProfile
        ),
        ".ideavimrc"
    ) = ".ideavimrc"

    [System.IO.Path]::Combine(
        [Environment]::GetFolderPath(
            [Environment+SpecialFolder]::UserProfile
        ),
        "keymap.vim"
    ) = "keymap.vim"
}

# Define how each file should be copied
$fileHandling = @{
    ".obsidian.vimrc" = "targetToSubDir"
    ".ideavimrc"      = "targetToDir"
    "keymap.vim"      = "targetToDir"
}

foreach ($path in $paths.Keys) {
    $fileName = $paths[$path]

    # Handle the Neovim configuration directory separately
    if ($fileName -eq "nvim/") {
        $sourceNvimPath = Join-Path `
            -Path $scriptVimKeyMapSubDir `
            -ChildPath "nvim"

        if (-not (Test-Path -LiteralPath $sourceNvimPath -PathType Container)) {
            Write-Host "Source directory does not exist: $sourceNvimPath"
            Write-Host "------------------------------"
            continue
        }

        if (Test-Path -LiteralPath $path -PathType Container) {
            Write-Host "Directory exists: $path"

            $userChoice = Read-Host (
                "Do you want to completely remove and overwrite " +
                "the nvim directory at $path? (y[es]/n[o])"
            )

            $userChoice = $userChoice.Trim().ToLower()

            if ($userChoice -eq "y" -or $userChoice -eq "yes") {
                Remove-Item `
                    -LiteralPath $path `
                    -Recurse `
                    -Force

                Write-Host "Old nvim directory removed."

                Copy-Item `
                    -LiteralPath $sourceNvimPath `
                    -Destination $path `
                    -Recurse `
                    -Force

                Write-Host "Directory overwritten successfully at $path"
            } else {
                Write-Host "Skipped: $path"
            }
        } else {
            Write-Host "Directory does not exist: $path"
        }

        Write-Host "------------------------------"
        continue
    }

    $sourceFilePath = Join-Path `
        -Path $scriptVimKeyMapSubDir `
        -ChildPath $fileName

    $fullFilePath = Join-Path `
        -Path $path `
        -ChildPath $fileName

    $directoryPath = Split-Path `
        -Path $fullFilePath `
        -Parent

    if (-not (Test-Path -LiteralPath $sourceFilePath -PathType Leaf)) {
        Write-Host "Source file does not exist: $sourceFilePath"
        Write-Host "------------------------------"
        continue
    }

    if (-not (Test-Path -LiteralPath $path)) {
        Write-Host "Target path does not exist: $path"
        Write-Host "------------------------------"
        continue
    }

    $handlingType = $fileHandling[$fileName]

    switch ($handlingType) {
        "targetToSubDir" {
            Write-Host "Target file: $fullFilePath"

            $userChoice = Read-Host (
                "Do you want to overwrite the file at " +
                "$fullFilePath? (y[es]/n[o])"
            )

            $userChoice = $userChoice.Trim().ToLower()

            if ($userChoice -eq "y" -or $userChoice -eq "yes") {
                Copy-Item `
                    -LiteralPath $sourceFilePath `
                    -Destination $fullFilePath `
                    -Force

                Write-Host "File overwritten successfully at $fullFilePath"
            } else {
                Write-Host "Skipped: $fullFilePath"
            }
        }

        "targetToDir" {
            Write-Host "Target file: $fullFilePath"

            $userChoice = Read-Host (
                "Do you want to overwrite the file at " +
                "$fullFilePath? (y[es]/n[o])"
            )

            $userChoice = $userChoice.Trim().ToLower()

            if ($userChoice -eq "y" -or $userChoice -eq "yes") {
                Copy-Item `
                    -LiteralPath $sourceFilePath `
                    -Destination $directoryPath `
                    -Force

                Write-Host "File overwritten successfully at $fullFilePath"
            } else {
                Write-Host "Skipped: $fullFilePath"
            }
        }

        default {
            Write-Host "Unknown handling type for: $fileName"
        }
    }

    Write-Host "------------------------------"
}

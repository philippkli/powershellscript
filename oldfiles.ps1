#Ab dieser Anzahl an Tagen wird die Datei aufgerufen
param (
    [int]$days = 30
)
# Manuell den Pfad eingeben
# $directory = ""
# oder das Skript in den Ordner einfügen, alle Unterordner werden dabei auch in Betracht gezogen
$directory = $PSScriptRoot

#Das heutige Datum erhalten
$currentDate = Get-Date

#Das "Deadline" Datum errechnen
$cutoffDate = $currentDate.AddDays(-$days)

#Datein finden, die älter sind als das Deadline Datum
$oldFiles = Get-ChildItem -Path $directory | Where-Object { $_.LastWriteTime -lt $cutoffDate}

#Schleife mit gekürztem Pfad im Output
foreach ($file in $oldFiles) {
    $relativePath = $file.FullName.Replace($directory, "").TrimStart("\")
    Write-Host "Datei $relativePath ist aelter als $days tage"
}

# Nutzer frage, ob die alten Datein gezippt werden sollen
$compressOldFiles = Read-Host "Moechten Sie die alten Dateien komprimieren? (Y/N)"

if ($compressOldFiles -eq "Y" -or $compressOldFiles -eq "y") {
    # Name/Zeit für .zip Datein erstellen
    $timestamp = Get-Date -Format "yyyMMddHHmm"
    
    # Zip Datei erstellen
    $zipFileName = "OldFiles_$timestamp.zip"
    $zipPath = Join-Path -Path $directory -ChildPath $zipFileName
    
    # Datein komprimieren
    Compress-Archive -Path $oldFiles.FullName -DestinationPath $zipPath
    
    Write-Host "Datein die aelter als $days Tage waren, wurden in $zipFileName komprimiert"
} else {
    "Alte Datein wurden nicht komprimiert"
}

# Nutzer fragen, ob die alten Datein gelöscht werden sollen
$deleteOldFiles = Read-Host "Moechten Sie die alten unkomprimierten Dateien loeschen? (Y/N)"

if ($deleteOldFiles -eq "Y" -or $deleteOldFiles -eq "y") {
    foreach ($file in $oldFiles) {
        #Remove-Item -Path $file.FullName -Force
        Write-Host "$($file.FullName) wurde 'geloescht'"
    }
    Write-Host "Alte Datein wurden geloescht"
} else {
    Write-Host "Alte Datein wurden nicht geloescht"
}

Pause
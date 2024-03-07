#Ab dieser Anzahl an Tagen wird die Datei aufgerufen
param (
    [int]$days = 30
)
# Manuell den Pfad eingeben
# $directory = "C:\Users\AV01KZV\OneDrive - Volkswagen AG\Documents"
# oder das Skript in den Ordner einfügen, alle Unterordner werden dabei auch in Betracht gezogen
$directory = $PSScriptRoot

#Das heutige Datum erhalten
$currentDate = Get-Date

#Das "Deadline" Datum errechnen
$cutoffDate = $currentDate.AddDays(-$days)

#Datein finden, die älter sind als das Deadline Datum
$oldFiles = Get-ChildItem -Path $directory -Recurse | Where-Object { $_.LastWriteTime -lt $cutoffDate}

# Name/Zeit für .zip Datein erstellen
$timestamp = Get-Date -Format "yyyMMddHHmmss"

# Zip Datei erstellen
$zipFileName = "OldFiles_$timestamp.zip"
$zipPath = Join-Path -Path $directory -ChildPath $zipFileName

# Datein komprimieren
Compress-Archive -Path $oldFiles.FullName -DestinationPath $zipPath

Write-Host "Datein die älter als $days Tage waren, wurden in $zipFileName komprimiert"

#Schleife mit ganzem Pfad im Output
#foreach ($file in $oldFiles) {
#    Write-Host "Datei $($file.FullName) ist aelter als $days tage."
#}

#Schleife mit gekürztem Pfad im Output
foreach ($file in $oldFiles) {
    $relativePath = $file.FullName.Replace($directory, "").TrimStart("\")
    Write-Host "Datei $relativePath ist aelter als $days tage."
}

Pause
# Beschreibung: Dieses Skript dient dazu, spezifizierte alte Dateien zu komprimieren und zu löschen.
# Durch Parametern oder durch manuelle Eingabe kann entschieden werden, ab welchem "alter" Dateien berücksichtigt, ob sie komprimiert oder gelöscht werden. 
# Datum: 12.03.2023 DD/MM/YYYY
# Autor: Philipp Klingert (A-GSAA-W2 | philipp.klingert@volkswagen-groupservices.com)
# Parameterliste: -days <int> -zip Y/N -del Y/N -log Y/N

param (
    # Parameter gibt den Maximalwert in Tagen an. Alle Dateien die älter sind als der gegebene Wert werden betrachtet 
    [int]$days = 0,
    # Parameter ob die Dateien komprimiert werden sollen oder nicht
    [string]$zip = "N",
    # Parameter ob die Dateien nach der komprimierung gelöscht werden sollen
    [string]$del = "N",
    # Parameter ob das Skript in Powershell den Vorgang wiedergibt
    [string]$log = "N"
)
# Der Ordner in dem sich das Script befindet
$currentDirectory = $PSScriptRoot
# Das heutige Datum erhalten
$currentDate = Get-Date

# Wird nur aufgerufen, wenn das Skript ohne jegliche Parameter aufgerufen wird - bspw. rechtsclick -> mit powershell ausführen
# Fragt dementsprechend nach manuellen Eingaben und gibt automatisch den Vorgang wieder
if ($days -eq 0 -and $zip -eq "N" -and $del -eq "N") {
    $days = Read-Host "Geben Sie die Anzahl der Tage ein"
    #Das manuell gesetzte "Deadline" Datum errechnen
    $cutoffDate = $currentDate.AddDays(-$days)
    #Datein finden, die älter sind als das anuell gesetzte Deadline Datum
    $oldFiles = Get-ChildItem -Path $currentDirectory | Where-Object { $_.LastWriteTime -lt $cutoffDate}
    #Zeigt dem User an, welche Dateien älter sind als $days
    foreach ($file in $oldFiles) {
        $relativePath = $file.FullName.Replace($currentDirectory, "").TrimStart("\")
        Write-Host "Datei $relativePath ist aelter als $days tage"
    }
    # Nutzer fragen, ob die alten Datein komprimiert werden sollen
    $zip = Read-Host "Moechten Sie die alten Dateien komprimieren? (Y/N)"
    # Nutzer fragen, ob die alten Datein gelöscht werden sollen
    $del = Read-Host "Moechten Sie die alten Dateien loeschen? (Y/N)"
    # Setzt die Variable $log auf Y, da sobald diese if-Abfrage greift, ein Mensch auf das Terminal schaut und den Vorgang sehen soll
    $log = "Y"
}

# Das "Deadline" Datum errechnen
$cutoffDate = $currentDate.AddDays(-$days)
# Datein finden, die älter sind als das Deadline Datum
$oldFiles = Get-ChildItem -Path $currentDirectory | Where-Object { $_.LastWriteTime -lt $cutoffDate}

# Wenn die Dateien komprimiert werden sollen, dann wird der folgende Code ausgeführt
if ($zip -eq "Y" -or $zip -eq "y") {
    foreach ($file in $oldFiles) {
        # Name/Zeit für .zip Datein erstellen
        $timestamp = Get-Date -Format "yyyMMddHHmm"
        # Zip Datei erstellen
        $zipFileName = "old_$($file.BaseName)_$timestamp.zip"
        $zipPath = Join-Path -Path $currentDirectory -ChildPath $zipFileName
        # Datein komprimieren
        Compress-Archive -Path $file.FullName -DestinationPath $zipPath
        if ($log -eq "Y" -or $log -eq "y") {
            Write-Host "Datei $($file.FullName) wurde in $zipFileName komprimiert" #test
        }
    }
} else {
    if ($log -eq "Y" -or $log -eq "y") {
        Write-Host "Dateien wurden nicht komprimiert" #test
    }
}

# Wenn die alten unkomprimierten Dateien gelöscht werden sollen, dann wird der folgende Code ausgeführt
if ($del -eq "Y" -or $del -eq "y") {
    foreach ($file in $oldFiles) {
        # Löscht die alten unkomprimierten Dateien. VORSICHT!!!!!
        Remove-Item -Path $file.FullName -Force
        if ($log -eq "Y" -or $log -eq "y") {
        Write-Host "$($file.FullName) wurde 'geloescht'" #test
        }
    }
    if ($log -eq "Y" -or $log -eq "y") {
    Write-Host "Alte Dateien wurden erfolgreich geloescht" #test
    }
} else {
    if ($log -eq "Y" -or $log -eq "y") {
    Write-Host "Alte Dateien wurden nicht geloescht" #test
    }
}

if ($log -eq "Y" -or $log -eq "y") {
    Pause
}
# Beschreibung: Dieses Skript dient dazu, spezifizierte alte Dateien zu komprimieren und zu lÃ¶schen.
# Durch Parametern oder durch manuelle Eingabe kann entschieden werden, ab welchem "alter" Dateien berÃ¼cksichtigt, ob sie komprimiert oder gelÃ¶scht werden. 
# Datum: 12.03.2023 DD/MM/YYYY
# Autor: Philipp Klingert (A-GSAA-W2 | philipp.klingert@volkswagen-groupservices.com)
# Parameterliste: -days <int> -zip [Y/N] -del [Y/N] -log [Y/N]

# History
# 14.03.2024 Bernd Winger  ZIP-Funktion für Powershell 4 implementiert

param (
    # Parameter gibt den Maximalwert in Tagen an. Alle Dateien die Ã¤lter sind als der gegebene Wert werden betrachtet 
    [int]$days = 0,
    # Parameter ob die Dateien komprimiert werden sollen oder nicht
    [string]$zip = "N",
    # Parameter ob die Dateien nach der komprimierung gelÃ¶scht werden sollen
    [string]$del = "N",
    # Parameter logPath
    [string]$logPath = ""
    )

Add-Type -assembly "system.io.compression.filesystem"


# PrÃ¼fen der Parameter - LÃ¶scht Leerzeilen & macht alles Uppercase & reduziert den String auf das erste Zeichen
$zip = $zip.ToUpper().Trim()
$zip = $zip[0]
$del = $del.ToUpper().Trim()
$del = $del[0]

# Das heutige Datum erhalten
$currentDate = Get-Date
$log = "N"

# Prüfung logPath
if ($logPath -eq "") {
  write-host "Pfad nicht angegeben"
  exit 3
  }

if ( -not (Test-Path $logPath )) {
  write-host "Pfad nicht gefunden"
  exit 2
  }

# Wird nur aufgerufen, wenn das Skript ohne jegliche Parameter aufgerufen wird - bspw. rechtsclick -> mit powershell ausfÃ¼hren
# Fragt dementsprechend nach manuellen Eingaben und gibt automatisch den Vorgang wieder
if ($days -eq 0) {
  $days = Read-Host "Geben Sie die Anzahl der Tage ein"
  #Das manuell gesetzte "Deadline" Datum errechnen
  $cutoffDate = $currentDate.AddDays(-$days)
  #Datein finden, die Ã¤lter sind als das anuell gesetzte Deadline Datum
  $oldFiles = Get-ChildItem -Path $logPath | Where-Object { $_.LastAccessTime -lt $cutoffDate}

  Write-Host "Anzahl zu löschender Files: $oldFiles.Count"
  $log = "Y"
  } # end if: ($days -eq 0)

if ($zip -eq "N") {
  # Nutzer fragen, ob die alten Datein komprimiert werden sollen
  $zip = Read-Host "Moechten Sie die alten Dateien komprimieren? (Y/N)"
  $log = "Y"
  }

if ($del -eq "N") {
  # Nutzer fragen, ob die alten Datein gelÃ¶scht werden sollen
  $del = Read-Host "Moechten Sie die alten Dateien loeschen? (Y/N)"
  $log = "Y"
  }

# Prüfen der Parameter - Falls Anwender änderungen gemacht hat
$zip = $zip.ToUpper().Trim()
$zip = $zip[0]
$del = $del.ToUpper().Trim()
$del = $del[0]


# Wenn die Dateien komprimiert werden sollen, dann wird der folgende Code ausgefÃ¼hrt
if ($zip -eq "Y") {
    # Das "Deadline" Datum errechnen
    $zipDate = $currentDate.AddDays(-1)
    # Datein finden, die Ã¤lter sind als das Deadline Datum
    $zipFiles = Get-ChildItem -Path $logPath | Where-Object { $_.LastAccessTime -lt $zipDate -and $_.Extension -ne ".zip"}

    foreach ($zipFile in $zipFiles) {
        # Datein komprimieren
        if ( $PSVersionTable.PSVersion.Major -eq 4) {
          $zipArchive = $zipFile.DirectoryName + '\' + $zipFile.Name + ".zip"
          $zipPath = $zipFile.DirectoryName
          $zipDest = $zipFile.Name 

          $zipHandle = [System.IO.Compression.ZipFile]::Open($zipArchive, 'create')
          $zipHandle.Dispose()
          $zipCompression = [System.IO.Compression.CompressionLevel]::Optimal
          $zipHandle = [System.IO.Compression.ZipFile]::Open($zipArchive, 'update')

          [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipHandle, $zipFile.FullName , $zipDest, $zipCompression) | Out-Null

          $zipHandle.Dispose()

          # [io.compression.zipfile]::CreateFromDirectory($zipFile,$zipFileName)
          # [io.compression.zipfile]::CreateFromFile($zipFile.FullName,$zipFileName)
          } else {
          # Name und Zip Datei erstellen
          $zipFileName = $zipFile.DirectoryName + '\' + $zipFile.Name + ".zip"
          # Original Philipp
           #Compress-Archive -Path $zipFile -DestinationPath $zipFileName

          # Original Bernd
           #Compress-Archive -Path $zipFile.FullName -DestinationPath $zipFileName

          }
        # write "remove: $zipFile"
        Remove-Item $zipFile.FullName
        if ($log -eq "Y") {
            Write-Host "Datei $($zipFile) wurde in $zipFileName komprimiert" #test
        }
    }
} else {
    if ($log -eq "Y") {
        Write-Host "Dateien wurden nicht komprimiert" #test
    }
}

# Wenn die alten unkomprimierten Dateien gelÃ¶scht werden sollen, dann wird der folgende Code ausgefÃ¼hrt
if ($del -eq "Y") {
    # Das "Deadline" fÃ¼rs lÃ¶schen Datum errechnen
    $cutoffDate = $currentDate.AddDays(-$days)
    $oldFiles = Get-ChildItem -Path $logPath | Where-Object { $_.LastAccessTime -lt $cutoffDate}
    foreach ($file in $oldFiles) {
        # LÃ¶scht die alten unkomprimierten Dateien. VORSICHT!!!!!
        Remove-Item -Path $file.FullName -Force
        # Write-Host "Lösche: $file.FullName $file.LastAccessTime"
        if ($log -eq "Y") {
          Write-Host "$($file.FullName) wurde 'geloescht'" 
          }
    }
    if ($log -eq "Y") {
      Write-Host "Alte Dateien wurden erfolgreich geloescht" 
      }
} else {
    if ($log -eq "Y") {
      Write-Host "Alte Dateien wurden nicht geloescht"
      }
}

if ($log -eq "Y") {
    Pause
}

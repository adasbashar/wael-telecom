# CI entry point: installs Inno Setup if missing, builds both stores, packages output.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..
Start-Transcript -Path build-win.log -Force
try {
  dotnet --info | Select-Object -First 8
  $iscc = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
  if (-not (Test-Path $iscc)) {
    Write-Host "Installing Inno Setup..."
    try { choco install innosetup -y --no-progress | Out-Host } catch { Write-Host "choco failed: $_" }
    if (-not (Test-Path $iscc)) {
      Invoke-WebRequest "https://jrsoftware.org/download.php/is.exe" -OutFile "$env:TEMP\is.exe"
      Start-Process "$env:TEMP\is.exe" -ArgumentList "/VERYSILENT","/SUPPRESSMSGBOXES","/NORESTART","/SP-" -Wait
    }
  }
  if (-not (Test-Path $iscc)) { throw "Inno Setup not available" }

  $root = (Get-Location).Path
  foreach ($s in @("wael","sham")) { & "$PSScriptRoot\build.ps1" -Store $s; Set-Location $root }

  New-Item -ItemType Directory -Force out | Out-Null
  Copy-Item windows\out\*.exe out\
  Compress-Archive -Path windows\dist\wael\* -DestinationPath out\WaelTelecom-Portable.zip -Force
  Compress-Archive -Path windows\dist\sham\* -DestinationPath out\ShamTelecom-Portable.zip -Force
  Get-ChildItem out | Select-Object Name, Length | Format-Table -AutoSize
}
catch { Write-Host "BUILD FAILED: $_"; Write-Host $_.ScriptStackTrace; Stop-Transcript; exit 1 }
Stop-Transcript

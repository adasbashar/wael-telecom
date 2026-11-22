# Builds the Windows app + installer for one store.  Usage:  ./build.ps1 -Store wael
param([string]$Store = "wael")
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
dotnet build StoreApp.csproj --no-incremental -c Release -p:Store=$Store -o "dist\$Store"
if ($LASTEXITCODE -ne 0) { throw "dotnet build failed" }
New-Item -ItemType Directory -Force "dist\$Store\app" | Out-Null
Copy-Item ..\app\src\main\assets\* "dist\$Store\app\" -Force
Copy-Item "..\app\src\$Store\assets\*" "dist\$Store\app\" -Force
Remove-Item "dist\$Store\*.pdb","dist\$Store\*.xml" -ErrorAction SilentlyContinue
Get-ChildItem -Recurse "dist\$Store" | Select-Object FullName, Length | Format-Table -AutoSize
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DStore=$Store setup.iss
if ($LASTEXITCODE -ne 0) { throw "Inno Setup failed" }

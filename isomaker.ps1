# ---
# Type        : SCRIPT
# Auteur      : Louis MEDO - louis.medo@loutik.fr
# Date        : 28/05/2026
# Rôle        : Création d'une image ISO de configuration pour Cloudbase-Init avec personnalisation du nom d'hôte et de l'adresse IP
# ---

param (
    [Parameter(Mandatory=$true)][string]$NomMachine,
    [Parameter(Mandatory=$true)][string]$AdresseIP,
    [Parameter(Mandatory=$true)][string]$Masque,
    [Parameter(Mandatory=$true)][string]$Passerelle,
    [Parameter(Mandatory=$true)][string]$DNS,
    [string]$TemplateDir = "$PSScriptRoot\ConfigDrive",
    [string]$TempDir = "$PSScriptRoot\tmp\ConfigDrive",
    [string]$IsoDir = "$PSScriptRoot"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 0. Vérification de l'outil oscdimg
$OscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
if (-not (Test-Path -Path $OscdimgPath)) {
    Write-Error "L'utilitaire oscdimg.exe est introuvable. Veuillez installer le Windows ADK."
    exit 1
}

# 1. Création du dossier temporaire et copie
if (-not (Test-Path -Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}
Copy-Item -Path "$TemplateDir\*" -Destination $TempDir -Recurse -Force

# 2. Remplacement du nom d'hôte (JSON)
$MetaFile = "$TempDir\openstack\latest\meta_data.json"
$JsonContent = Get-Content -Path $MetaFile | ConvertFrom-Json
$JsonContent.hostname = $NomMachine
$JsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $MetaFile

# 3. Remplacement des configurations réseau dans user_data
$UserDataFile = "$TempDir\openstack\latest\user_data"
$UserDataContent = Get-Content -Path $UserDataFile

$UserDataContent = $UserDataContent -replace '-IPAddress "1\.1\.1\.1"', "-IPAddress `"$AdresseIP`""
$UserDataContent = $UserDataContent -replace '-PrefixLength 24', "-PrefixLength $Masque"
$UserDataContent = $UserDataContent -replace '-DefaultGateway "1\.1\.1\.1"', "-DefaultGateway `"$Passerelle`""
$UserDataContent = $UserDataContent -replace '-ServerAddresses "1\.1\.1\.1"', "-ServerAddresses `"$DNS`""

$UserDataContent | Set-Content -Path $UserDataFile

# 4. Génération de l'ISO avec oscdimg
$UuidCourt = (New-Guid).Guid.Substring(0,8)
$IsoPath = "$IsoDir\cloudbase-$NomMachine-$UuidCourt.iso"
Write-Host "Génération de l'ISO en cours..." -ForegroundColor Cyan
& $OscdimgPath -m -n -lconfig-2 "$TempDir" "$IsoPath"

# 5. Nettoyage du dossier temporaire
Remove-Item -Path "$PSScriptRoot\tmp" -Recurse -Force
Write-Host "Opération terminée avec succès !" -ForegroundColor Green
<#
viset_installer.ps1

Jednoduchý samostatný inštalátor pre Viset.
Spustite tento skript v priečinku C:\Users\<you>\Desktop\VSET\viset (alebo kdekoľvek chcete). Skript stiahne ZIP s projektom a rozbalí ho do rovnakého priečinka.

Použitie:
  PowerShell -NoProfile -ExecutionPolicy Bypass -File .\viset_installer.ps1 -Url "https://example.com/viset-full.zip"
  alebo spustite bez parametra a script sa vás opýta na URL.

Parametre:
  -Url       Priama URL na .zip archív s Viset. Ak je poskytnutá, skript stiahne bez ďalších otázok.
  -Overwrite Prepíše existujúce súbory v priečinku bez otázky.
  -AutoYes   Bez potvrdení (používajte opatrne).

Bezpečnosť: Skript nebude spúšťať žiadne binárky po stiahnutí. Po rozbalení môžete spustiť build_exe.ps1 ak chcete vytvoriť EXE.
#>
param(
    [string]$Url,
    [switch]$Overwrite,
    [switch]$AutoYes
)

function Info($s){ Write-Host "[INFO] $s" -ForegroundColor Cyan }
function Warn($s){ Write-Host "[WARN] $s" -ForegroundColor Yellow }
function Err($s){ Write-Host "[ERROR] $s" -ForegroundColor Red }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$targetDir = $scriptDir
Info "Inštalátor beží v: $scriptDir"

if (-not $Url){
    if (-not $AutoYes){
        Write-Host "Zadajte priamu URL na .zip archív s Viset (musí končiť .zip):"
        $Url = Read-Host
    } else {
        Err "Parameter -Url je povinný pri -AutoYes. Ukončujem."
        exit 1
    }
}

if (-not $Url){ Err "Žiadna URL nezadaná. Ukončujem."; exit 1 }

if ($Url -notmatch '\.zip($|\?)'){
    Warn "Zadaná URL nevyzerá ako .zip. Pokračovať? (Y/N)"
    if (-not $AutoYes){ $a = Read-Host; if ($a -notmatch '^[Yy]'){ Info "Ukonecujem."; exit 1 } }
}

# Stiahnuť do TEMP
$tmp = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName() + '.zip')
Info "Sťahujem $Url -> $tmp"
try{
    Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing -ErrorAction Stop
} catch {
    Err "Stiahnutie zlyhalo: $_"
    if (Test-Path $tmp){ Remove-Item $tmp -Force }
    exit 1
}

# Rozbaliť do dočasného priečinka
$extract = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $extract | Out-Null
Info "Rozbaľujem do: $extract"
try{
    Expand-Archive -LiteralPath $tmp -DestinationPath $extract -Force -ErrorAction Stop
} catch {
    Err "Rozbalenie zlyhalo: $_"
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    Remove-Item $extract -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Ak zip obsahuje top-level priecinok, použijeme ho
$children = Get-ChildItem -LiteralPath $extract | Where-Object { $_.Name -ne '.' -and $_.Name -ne '..' }
$sourceRoot = $extract
if ($children.Count -eq 1 -and $children[0].PSIsContainer){
    $sourceRoot = $children[0].FullName
}

Info "Kopírujem obsah $sourceRoot -> $targetDir"
if ($Overwrite){
    Info "Prepíšem cieľový priečinok: $targetDir"
    try{ Remove-Item -LiteralPath $targetDir -Recurse -Force -ErrorAction Stop } catch { }
    New-Item -ItemType Directory -Path $targetDir | Out-Null
} else {
    # ak nie je AutoYes, upozorni používateľa ak existujú súbory
    $existing = Get-ChildItem -LiteralPath $targetDir -Force | Where-Object { $_.Name -ne '.' -and $_.Name -ne '..' }
    if ($existing.Count -gt 0){
        Write-Host "Cieľový priečinok už obsahuje súbory. Prepísať/mergeovať? (Y/N)" -ForegroundColor Yellow
        if (-not $AutoYes){ $r = Read-Host } else { $r = 'Y' }
        if ($r -notmatch '^[Yy]'){ Info "Ukončené používateľom."; Remove-Item $tmp -Force -ErrorAction SilentlyContinue; Remove-Item $extract -Recurse -Force -ErrorAction SilentlyContinue; exit 0 }
    }
}

try{
    Copy-Item -Path (Join-Path $sourceRoot '*') -Destination $targetDir -Recurse -Force -ErrorAction Stop
} catch {
    Err "Kopírovanie zlyhalo: $_"
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    Remove-Item $extract -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Clean up
Remove-Item $tmp -Force -ErrorAction SilentlyContinue
Remove-Item $extract -Recurse -Force -ErrorAction SilentlyContinue

Info "Hotovo. Súbory boli stiahnuté a sú v: $targetDir"
Info "Ďalšie kroky: otvorte $targetDir\gui a spustite build_exe.ps1 ak chcete vytvoriť EXE." 
Write-Host "Ak chcete, môžete teraz spustiť: PowerShell -NoProfile -ExecutionPolicy Bypass -File \"$targetDir\gui\build_exe.ps1\"" -ForegroundColor Green

exit 0

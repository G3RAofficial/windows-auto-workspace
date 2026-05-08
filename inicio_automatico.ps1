# ============================================================
# SCRIPT DE INICIO AUTOMATICO - Windows Workspace Setup
# Configura 3 escritorios virtuales con apps posicionadas
# automaticamente al encender la PC
# ============================================================
# INSTRUCCIONES:
# 1. Reemplaza las rutas de las apps segun tu sistema
# 2. Ajusta $offX segun la posicion de tu monitor externo
# 3. Agrega o quita apps segun tus necesidades
# ============================================================
 
Import-Module VirtualDesktop
 
# ------------------------------------------------------------
# RUTAS DE LAS APPS - PERSONALIZA ESTAS RUTAS
# ------------------------------------------------------------
$brave       = "C:\TU RUTA"
$antigravity = "C:\TU RUTA"
$dicloak     = "C:\TU RUTA"
$ytmusic     = "C:\TU RUTA"
 
# AppIDs Microsoft Store - obtener con: Get-StartApps | Where-Object {$_.Name -like "*NombreApp*"}
$claudeAppID = "APPID_DE_CLAUDE"    # Ej: Claude_xxxxxxxxxx!Claude
$whatsappID  = "APPID_DE_WHATSAPP"  # Ej: 5319275A.WhatsAppDesktop_xxxxxxxxxx!App
 
# URLs PWA en Brave - puedes cambiarlas por cualquier URL
$googlekeep  = "--app=https://keep.google.com"
$googletasks = "--app=https://tasks.google.com"
$googlecal   = "--app=https://calendar.google.com"
 
# ------------------------------------------------------------
# CONFIGURACION DE MONITORES
# Monitor externo a la IZQUIERDA:  $offX = -1920
# Monitor externo a la DERECHA:    $offX = 1920
# Ajusta el valor segun tu resolucion si es diferente a 1920x1080
# ------------------------------------------------------------
$offX = -1920
 
# ------------------------------------------------------------
# FUNCIONES - NO ES NECESARIO MODIFICAR ESTA SECCION
# ------------------------------------------------------------
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinHelper {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
}
"@
 
function Wait-ForWindow($process, $timeoutSec = 30) {
    $elapsed = 0
    while ($elapsed -lt $timeoutSec) {
        $process.Refresh()
        if ($process.MainWindowHandle -ne 0) { return $true }
        Start-Sleep -Milliseconds 500
        $elapsed += 0.5
    }
    return $false
}
 
function Wait-ForStoreApp($processName, $timeoutSec = 30) {
    $elapsed = 0
    while ($elapsed -lt $timeoutSec) {
        $proc = Get-Process | Where-Object { $_.Name -like "*$processName*" -and $_.MainWindowHandle -ne 0 } | Select-Object -First 1
        if ($proc) { return $proc }
        Start-Sleep -Milliseconds 500
        $elapsed += 0.5
    }
    return $null
}
 
function Wait-ForBraveByTitle($title, $timeoutSec = 30) {
    $elapsed = 0
    while ($elapsed -lt $timeoutSec) {
        $proc = Get-Process brave -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*$title*" } | Select-Object -First 1
        if ($proc) { return $proc }
        Start-Sleep -Milliseconds 500
        $elapsed += 0.5
    }
    return $null
}
 
function Move-Window($process, $x, $y, $w, $h) {
    [WinHelper]::ShowWindow($process.MainWindowHandle, 9)
    Start-Sleep -Milliseconds 500
    [WinHelper]::SetWindowPos($process.MainWindowHandle, [IntPtr]::Zero, $x, $y, $w, $h, 0x0040)
    Start-Sleep -Milliseconds 400
    [WinHelper]::SetWindowPos($process.MainWindowHandle, [IntPtr]::Zero, $x, $y, $w, $h, 0x0040)
}
 
# ------------------------------------------------------------
# ESPERAR QUE WINDOWS TERMINE DE CARGAR
# Aumenta este valor si tu PC tarda mas en iniciar
# ------------------------------------------------------------
Write-Host "Esperando que Windows termine de cargar..."
Start-Sleep -Seconds 15
 
# ============================================================
# CREAR 3 ESCRITORIOS VIRTUALES
# ============================================================
Write-Host "Creando escritorios virtuales..."
$desktops = Get-DesktopList
while ($desktops.Count -lt 3) {
    New-Desktop | Out-Null
    $desktops = Get-DesktopList
}
 
# ============================================================
# ESCRITORIO 3 - PERSONAL
# Monitor externo: YouTube Music (der)
# Laptop: WhatsApp (der 50%)
# Keep, Tasks y Calendar se abren al final
# ============================================================
Write-Host "Abriendo Escritorio 3: Personal..."
Switch-Desktop (Get-Desktop -Index 2)
Start-Sleep -Milliseconds 800
 
# Monitor externo - YouTube Music
$procYTMusic = Start-Process $ytmusic -PassThru
if (Wait-ForWindow $procYTMusic) {
    Move-Window $procYTMusic ($offX + 1280) 0 640 1080
}
 
# Laptop - WhatsApp
Start-Process "explorer.exe" -ArgumentList "shell:AppsFolder\$whatsappID"
$procWA = Wait-ForStoreApp "WhatsApp"
if ($procWA) {
    Start-Sleep -Seconds 2
    Move-Window $procWA 960 0 960 1080
}
 
# ============================================================
# ESCRITORIO 2 - CURSOS
# Laptop: Brave (izq 69%) + Claude (der 31%)
# Monitor externo: DiCloak pantalla completa
# ============================================================
Write-Host "Abriendo Escritorio 2: Cursos..."
Switch-Desktop (Get-Desktop -Index 1)
Start-Sleep -Milliseconds 800
 
# Laptop - Brave
$procBrave = Start-Process $brave -PassThru
if (Wait-ForWindow $procBrave) {
    Move-Window $procBrave 0 0 1320 1080
}
 
# Laptop - Claude
Start-Process "explorer.exe" -ArgumentList "shell:AppsFolder\$claudeAppID"
$procClaude = Wait-ForStoreApp "claude"
if ($procClaude) {
    Start-Sleep -Seconds 2
    Move-Window $procClaude 1320 0 600 1080
}
 
# Monitor externo - DiCloak pantalla completa
$procDicloak = Start-Process $dicloak -PassThru
if (Wait-ForWindow $procDicloak) {
    Start-Sleep -Seconds 3
    Move-Window $procDicloak $offX 0 1920 1080
}
 
# ============================================================
# ESCRITORIO 1 - DESARROLLO
# Laptop: Antigravity pantalla completa
# Monitor externo: solo fondo
# ============================================================
Write-Host "Abriendo Escritorio 1: Desarrollo..."
Switch-Desktop (Get-Desktop -Index 0)
Start-Sleep -Milliseconds 800
 
$procAntigravity = Start-Process $antigravity -PassThru
if (Wait-ForWindow $procAntigravity) {
    Move-Window $procAntigravity 0 0 1920 1080
}
 
# ============================================================
# VOLVER A PERSONAL PARA ABRIR LAS PWAs DE BRAVE
# Se abren al final para evitar conflictos con otras instancias
# ============================================================
Write-Host "Abriendo PWAs en Escritorio 3: Personal..."
Switch-Desktop (Get-Desktop -Index 2)
Start-Sleep -Milliseconds 800
 
# Monitor externo - Google Keep
Start-Process $brave -ArgumentList $googlekeep
$procKeep = Wait-ForBraveByTitle "Keep"
if ($procKeep) {
    Move-Window $procKeep $offX 0 640 1080
}
 
# Monitor externo - Google Tasks
Start-Process $brave -ArgumentList $googletasks
$procTasks = Wait-ForBraveByTitle "Tasks"
if ($procTasks) {
    Move-Window $procTasks ($offX + 640) 0 640 1080
}
 
# Laptop - Google Calendar
Start-Process $brave -ArgumentList $googlecal
$procCal = Wait-ForBraveByTitle "Calendar"
if ($procCal) {
    Move-Window $procCal 0 0 960 1080
}
 
# ============================================================
# REGRESAR A DESARROLLO
# ============================================================
Start-Sleep -Seconds 1
Switch-Desktop (Get-Desktop -Index 0)
 
Write-Host "Todo listo! Escritorios configurados correctamente."
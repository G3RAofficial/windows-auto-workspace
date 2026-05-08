# 🖥️ Windows Auto Workspace Setup

> Automatiza la apertura y posicionamiento de tus apps favoritas en escritorios virtuales al encender tu PC con Windows.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=for-the-badge&logo=powershell)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=for-the-badge&logo=windows)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## ✨ ¿Qué hace?

Al encender tu PC, este script:

- 🗂️ Crea **3 escritorios virtuales** automáticamente
- 📐 Abre cada app en el **escritorio y posición exacta** que configuraste
- 🖥️ Soporta **configuraciones multi-monitor**
- ⏱️ Espera activamente a que cada app cargue antes de posicionarla

### Layout de ejemplo incluido

| Escritorio | Monitor externo | Laptop |
|---|---|---|
| 🔧 **Desarrollo** | Solo fondo | VS Code / Editor |
| 📚 **Cursos** | DiCloak (pantalla completa) | Brave (69%) + Claude (31%) |
| 👤 **Personal** | Keep + Tasks + YouTube Music | Calendar + WhatsApp |

---

## 📋 Requisitos

- Windows 10 u 11
- PowerShell 5.1 o superior
- Módulo **VirtualDesktop** instalado

---

## 🚀 Instalación

### 1. Instala el módulo VirtualDesktop

Abre PowerShell como **administrador** y ejecuta:

```powershell
Install-Module -Name VirtualDesktop -Scope CurrentUser -Force
```

Si te pide instalar NuGet, acepta con `Y`.

Verifica que se instaló correctamente:

```powershell
Get-Module -ListAvailable VirtualDesktop
```

### 2. Descarga el script

Clona el repositorio o descarga el archivo directamente:

```bash
git clone https://github.com/TU_USUARIO/windows-auto-workspace.git
```

### 3. Configura el script

Abre `inicio_automatico.ps1` y personaliza las siguientes variables:

#### 🗂️ Rutas de tus apps
```powershell
$brave       = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
$antigravity = "C:\Users\TU_USUARIO\AppData\Local\Programs\Antigravity\Antigravity.exe"
# ... agrega o quita apps según necesites
```

#### 🖥️ Posición del monitor externo
```powershell
# Monitor externo a la IZQUIERDA de la laptop:
$offX = -1920

# Monitor externo a la DERECHA de la laptop:
$offX = 1920
```

> 💡 Si tu resolución no es 1920x1080, cambia el valor por el ancho de tu pantalla.

#### 📦 Apps de Microsoft Store

Para apps instaladas desde la Store (WhatsApp, Claude, etc.), necesitas su AppID. Encuéntralo con:

```powershell
Get-StartApps | Where-Object {$_.Name -like "*NombreApp*"}
```

### 4. Configura el inicio automático

#### Opción A — Carpeta Startup (recomendado)

Crea un archivo `inicio.bat` en la carpeta de inicio de Windows:

1. Presiona `Win + R` y escribe `shell:startup`
2. Crea un nuevo archivo `inicio.bat` con este contenido:

```bat
@echo off
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\ruta\donde\guardaste\inicio_automatico.ps1"
```

#### Opción B — Ejecutar manualmente

```powershell
powershell.exe -ExecutionPolicy Bypass -File ".\inicio_automatico.ps1"
```

---

## ⚙️ Personalización

### Agregar una app normal (.exe)

```powershell
# 1. Define la ruta
$miApp = "C:\ruta\a\MiApp.exe"

# 2. Cambia al escritorio deseado y ábrela
Switch-Desktop (Get-Desktop -Index 0)
$proc = Start-Process $miApp -PassThru
if (Wait-ForWindow $proc) {
    Move-Window $proc 0 0 1920 1080   # X, Y, Ancho, Alto
}
```

### Agregar una app de Microsoft Store

```powershell
# 1. Obtén el AppID
Get-StartApps | Where-Object {$_.Name -like "*NombreApp*"}

# 2. Ábrela y espera
Start-Process "explorer.exe" -ArgumentList "shell:AppsFolder\AppID!App"
$proc = Wait-ForStoreApp "NombreProceso"
if ($proc) {
    Start-Sleep -Seconds 2
    Move-Window $proc 0 0 960 1080
}
```

### Agregar una PWA en Brave

```powershell
$miPWA = "--app=https://tuurl.com"
$proc = Start-Process $brave -ArgumentList $miPWA -PassThru
if (Wait-ForWindow $proc) {
    Move-Window $proc 0 0 960 1080
}
```

### Coordenadas de ventanas

El sistema de coordenadas funciona así con monitor externo a la **izquierda**:

```
|----- Monitor externo -----|--------- Laptop ---------|
|-1920                      0                       1920|
```

Con monitor externo a la **derecha**:

```
|--------- Laptop ----------|---- Monitor externo -----|
|0                       1920                       3840|
```

---

## 🔧 Solución de problemas

**Las apps no se abren en el escritorio correcto**
> Asegúrate de que el `Switch-Desktop` está antes de abrir cada app. Las apps nuevas se abren en el escritorio activo.

**Una app no respeta la posición asignada**
> Algunas apps UWP de Microsoft ignoran `SetWindowPos`. Prueba aumentar el `Start-Sleep` antes de `Move-Window`.

**El script termina antes de que carguen las apps**
> Aumenta el valor de `Start-Sleep -Seconds 15` al inicio del script según la velocidad de tu PC.

**Error: módulo VirtualDesktop no encontrado**
> Ejecuta `Install-Module -Name VirtualDesktop -Scope CurrentUser -Force` en PowerShell como administrador.

---

## 📄 Licencia

MIT — libre para usar, modificar y compartir.

---

<p align="center">Hecho con <img src="https://cdn3.emoji.gg/emojis/77080-whitemonster.png" width="30"/> y demasiadas horas de debugging</p>
# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).
Versionado: [SemVer](https://semver.org/lang/es/).

## [1.3.0] - 2026-06-13

### Agregado
- Script 10 pulido final: swappiness del host (150→10), DPI auto-detectado
  por resolución, color de escritorio azul Win10 (#1E3C78), resolución
  adaptativa a pantalla real, sandbox (Z: drive eliminado + winemenubuilder
  desactivado), y Windows Media Player 11
- Captura actualizada con aspecto azul oscuro a 1920x1080 fullscreen

### Documentado
- wmctrl crashea (segfault) con escritorios del tamaño exacto de la pantalla
  en XWayland; usar xdotool search --name como alternativa
- Clipboard Linux↔Wine funciona automáticamente via X11/XWayland sin config
- DPI auto: 96 (1080p), 120 (1440p), 144 (4K)

## [1.2.0] - 2026-06-12

### Agregado
- Script 09 tuning avanzado: NTSYNC (validación empírica con lsof — algunos
  builds de Wine no lo soportan), Wine Gecko 2.47.4 dual-arch, capa gráfica
  DXVK/VKD3D/D3DX9 (con verificación previa de Vulkan 1.3+), runtime VB6,
  nocrashdialog y VideoMemorySize
- Carpeta "Sistema" en el menú Inicio: winecfg, regedit, panel de control,
  desinstalador y CMD

### Documentado
- mdac28/jet40 no funcionan en prefixes win64 (límite de winetricks);
  alternativa: Access Database Engine per-app
- El verbo correcto es vb6run (no vbrun6); winetricks imprime su ayuda
  con EXIT=1 ante verbos inexistentes
- Pueden aparecer dos escritorios "shell" por carrera al lanzar apps justo
  tras crear el escritorio; cerrar con wineserver -k y reabrir

## [1.1.1] - 2026-06-12

### Corregido
- Menú Inicio: los .lnk de pylnk3 no resolvían en el shell de Wine ("Archivo
  no encontrado"). Ahora se crean con el propio shell32 de Wine mediante
  tools/CreateLnk.cs (IShellLink + IPersistFile) compilado con el csc del prefix
- Agregado acceso "Apagar Windows" (wineboot -k): el Exit del menú de Wine
  no siempre cierra el entorno

### Documentado
- Ventana negra al perder foco: problema conocido XWayland/compositores
  Wayland, cosmético, con mitigaciones en SOLUCION-PROBLEMAS.md

## [1.1.0] - 2026-06-12

### Agregado
- Script 07: apps básicas de Windows — Calculadora y Paint clásicos (Win32,
  funcionan donde las versiones UWP modernas no pueden) + dependencia MFC42
- Script 08: accesos del menú Inicio (carpeta Accesorios) generados con
  pylnk3, dado que el VBScript de Wine no implementa CreateShortcut
- Documentado el inventario de apps que Wine ya trae built-in (notepad,
  wordpad, taskmgr, regedit, cmd, control, msinfo32, clock, winver)

## [1.0.0] - 2026-06-12

### Agregado
- Scripts 01-06 + 99: instalación completa de Wine 11 estable, prefix maestro
  win64 como Windows 10, runtimes (VC++ 2005-2022, .NET 4.8, fuentes, MSXML,
  RichEdit, GDI+), mejoras visuales y lanzador de escritorio
- Escritorio virtual con barra de tareas y menú inicio (`/desktop=shell`)
- Fix del driver gráfico Wayland→x11 (ventanas invisibles en KDE Wayland)
- Suavizado ClearType RGB y sustitución de fuente Segoe UI→Tahoma
- Backup/restauración de imagen de fábrica del prefix
- Documentación: README, solución de problemas, apéndice experimental

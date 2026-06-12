# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).
Versionado: [SemVer](https://semver.org/lang/es/).

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

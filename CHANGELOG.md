# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).
Versionado: [SemVer](https://semver.org/lang/es/).

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

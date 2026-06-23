# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).
Versionado: [SemVer](https://semver.org/lang/es/).

## [1.8.0] - 2026-06-22

### Agregado
- **Capa de compilación `bin/wlbuild`**: compila proyectos .NET para el
  windows-like usando el SDK .NET del HOST como motor (no el compilador de Wine,
  que esta roto), y deja Wine solo como destino de ejecución. Dos targets:
  - `net48` (default): framework-dependent, lo ejecuta Wine Mono (validado:
    CLR 4.0.30319).
  - `net8`: self-contained win-x64, `.exe` autonomo que corre sin Mono
    (validado: CLR 8.0.28).
  Copia el binario a `C:\wlbuild\<proyecto>` y con `--run` lo lanza en Wine.

### Justificación
- El compilador embebido de Wine Mono falla (`MissingMethodException` en mcs;
  Roslyn falla por `DiaSymReader.Native` ausente) y el .NET Framework real exige
  desinstalar Wine Mono (rompiendo la compatibilidad de ejecución). Compilar en
  el host evita ambos problemas y no toca el prefix.

## [1.7.0] - 2026-06-20

### Cambiado
- **Base .NET migrada a Wine Mono** (`04-wine-mono.sh`, nuevo): reemplazo libre
  de .NET Framework hasta 4.8.1, instalado desde el `.msi` oficial 11.2.0
  (verificación de tamaño exacto anti-corrupción). Pasa a ser el método
  recomendado en lugar de `dotnet48`.
- `04-dotnet48.sh` degradado a **alternativa opcional**: el .NET 4.8 real solo
  se usa si una app concreta falla con Wine Mono. Motivo (evidencia de la
  comunidad + doc oficial): en prefix win64 el instalador de `dotnet48` es
  frágil (instalador roto, "Failed to open RpcSs service", conflictos de
  registro), mientras Wine Mono instala limpio y coexiste con .NET Core/5+.
  Ambos son mutuamente excluyentes para la serie 4.x.

### Agregado
- `04-wine-mono.sh`: instalación idempotente y reproducible de Wine Mono 11.2.0.

### Documentado
- corefonts, DXVK y VKD3D ya presentes en el prefix (scripts 03 y 09);
  confirmados vía `winetricks list-installed`. UWP/MSIX (Calculadora y Bloc de
  notas modernos) siguen sin soporte en Wine: se usan equivalentes Win32.

## [1.6.0] - 2026-06-14

### Agregado
- **Perfil unificado "Windows-like Luna"**: un solo comando `windows-like`
  combina, de forma idempotente y sin descargas externas:
  - escritorio "shell" con barra de tareas + menú Inicio,
  - esquema de colores clásico Windows XP "Luna Blue" aplicado por registro
    (`themes/xp-luna-blue.reg`: 31 colores + ClearType),
  - ventana fija 1366x768 (16:9) estable.
- `themes/xp-luna-blue.reg`: perfil declarativo reproducible (colores Luna,
  suavizado ClearType, shell, driver x11). Reemplaza la dependencia frágil de
  archivos `.msstyles` externos (Wine solo soporta temas era XP).
- Flag `--setup-only` para aplicar el perfil sin abrir el escritorio.
- Instalación del tema en ruta fija `~/.local/share/windows-like/` para que la
  copia del lanzador en `~/.local/bin/` lo encuentre.

### Corregido
- El lanzador instalado buscaba el `.reg` relativo a su ubicación
  (`~/.local/themes/`, inexistente) y saltaba el import en silencio. Ahora
  resuelve el tema en repo o en la ruta instalada.

## [1.5.1] - 2026-06-13

### Cambiado
- `bin/windows-like`: se elimina la detección automática del área de trabajo
  (resultó frágil entre monitores y bajo XWayland) y se fija la resolución en
  `1366x768` (16:9) en modo ventana. Simplicidad y estabilidad sobre
  adaptabilidad.

### Agregado
- `~/.local/bin/wine-shot`: captura solo la ventana de Wine bajo KDE Wayland
  vía X11 (`import -window`), sin spectacle, sin activar la ventana y sin
  interrumpir el trabajo del usuario.

### Documentado
- La barra de tareas del escritorio "shell" funciona; el "solo azul sin menú"
  era un artefacto de primer pintado de XWayland que se resuelve al interactuar.

## [1.5.0] - 2026-06-13

### Agregado
- Lanzador inteligente `bin/windows-like`: detecta el work area del monitor
  activo (`_NET_WORKAREA`), abre el escritorio a esa resolución y le quita el
  estado `_NET_WM_STATE_FULLSCREEN`, encajándolo en el área útil. La ventana
  ocupa todo menos los paneles de KDE y permite alternar entre aplicaciones.
  Reusa la sesión existente en vez de duplicarla.
- Ícono original propio `launcher/windows-like.svg` (marco de ventana con cuatro
  paneles, licencia MIT, sin reproducir logotipos de marca) + PNG 16–256.

### Cambiado
- `windows10-wine.desktop`: `Exec=windows-like` (antes resolución fija
  `1920x1080` que tapaba los paneles) e `Icon=windows-like`.

### Corregido
- Escritorio que tapaba los paneles de KDE: Wine marca el escritorio virtual
  como fullscreen y KDE lo coloca sobre los paneles. Se resuelve removiendo el
  estado fullscreen tras el arranque y fijando la geometría al work area; la
  resolución interna se iguala a la ventana para que la barra de tareas quede
  pegada al borde inferior.

## [1.4.0] - 2026-06-13

### Agregado
- Script 11: upgrade visual — fuentes Segoe UI reales (11 archivos extraídos
  de Windows 11 real vía SSH), charmap.exe nativo, y tema Windows 10 msstyles
  (8 MB, Botspot/wine-stuff)
- Acceso "Mapa de caracteres" en menú Inicio (Accesorios, total: 7 accesos)
- Total de fuentes en el prefix: 48 (antes 37)

### Cambiado
- Sustitución Segoe UI→Tahoma eliminada: ahora se usa la fuente Segoe UI real
  de Microsoft — diálogos y UI idéntica a Windows 10/11

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

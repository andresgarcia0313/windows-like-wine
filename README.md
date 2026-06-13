# windows-like-wine

Entorno **Windows 10 completo sobre Linux con Wine** — un solo prefix maestro con escritorio
virtual, barra de tareas, menú inicio y todos los runtimes que el software Windows espera
encontrar (Visual C++, .NET 4.8, fuentes, XML, GDI+).

Probado en **Kubuntu 26.04 (KDE Wayland)** con **Wine 11.0 estable**.

![Escritorio](docs/escritorio.png)

## ¿Qué obtienes?

- Prefix Wine win64 que se comporta como un **Windows 10 x64 build 19045 actualizado**
- **Escritorio virtual en ventana** con barra de tareas y menú inicio (`/desktop=shell`)
- Runtimes completos: VC++ 2005→2022, .NET Framework 4.8, MSXML, RichEdit, GDI+, 33 fuentes
- Suavizado de fuentes ClearType (RGB) y sustitución Segoe UI→Tahoma
- Lanzador en el menú de aplicaciones: **"Windows 10 (Wine)"**
- Backup "dorado" restaurable en 1 minuto

## Requisitos

| Requisito | Detalle |
|-----------|---------|
| Distro | Ubuntu/Kubuntu 24.04+ (o derivada con repos WineHQ) |
| Espacio | ~5 GB libres (prefix 2.4 GB + backup + caché) |
| RAM | 4 GB mínimo |
| Sesión | X11 o Wayland (el script fuerza XWayland, ver Solución de problemas) |

## Instalación rápida

```bash
git clone https://github.com/andresgarcia0313/windows-like-wine.git
cd windows-like-wine
./scripts/01-instalar-wine.sh      # Wine 11 estable + winetricks actualizado
./scripts/02-crear-prefix.sh       # prefix win64 + Windows 10
./scripts/03-runtimes.sh           # fuentes, VC++, XML, GDI+ (~30 min)
./scripts/04-dotnet48.sh           # .NET Framework 4.8 (~20 min)
./scripts/05-mejoras-visuales.sh   # ClearType, tema, escritorio con taskbar
./scripts/06-lanzador.sh           # entrada en el menú de aplicaciones
./scripts/07-apps-basicas.sh       # Calculadora y Paint clásicos
./scripts/08-menu-inicio.sh        # accesos en el menú Inicio (Accesorios)
./scripts/09-tuning-avanzado.sh    # NTSYNC, Gecko, DXVK, VB6, pulido
./scripts/99-backup.sh             # imagen de fábrica restaurable
```

## Apps de Windows incluidas

| App | Origen | Comando |
|-----|--------|---------|
| Bloc de notas, WordPad, Administrador de tareas, Regedit, CMD, Panel de control, Explorador | Built-in de Wine (reimplementaciones libres) | `wine notepad`, `wine write`, `wine taskmgr`... |
| Calculadora (con modo científico) | Clásica Win32 (script 07) | `wine calc` |
| Paint | Clásico Win32 (script 07) | `wine mspaint` |

Las versiones modernas de Calculadora/Paint/Notepad de Windows 10/11 son UWP
y **no funcionan en Wine** — las clásicas Win32 son el estándar de facto.

Al terminar: busca **"Windows 10 (Wine)"** en tu menú de aplicaciones.

## Decisiones de diseño (el porqué)

| Decisión | Razón |
|----------|-------|
| Prefix **win64** único | Wine 11 con WoW64 completo corre apps 32-bit sin libs 32-bit del sistema. Un prefix = un "Windows" coherente |
| **Windows 10** (no 11) | Versión que el 95% del software 2015-2026 espera; Win11 activa APIs que Wine traduce peor |
| Escritorio **"shell"** | Es el nombre mágico: activa barra de tareas + menú inicio del explorer de Wine |
| Driver gráfico **x11** | El driver Wayland (default en Wine 11) falla al crear ventanas en KDE Wayland y no soporta escritorio virtual |
| Overrides **por aplicación** | `winecfg → Aplicaciones` permite versión Windows y DLLs distintas por .exe sin crear más prefixes |
| Instalación **secuencial** | Dos winetricks simultáneos sobre el mismo prefix corrompen el registro |

## Errores conocidos que estos scripts evitan

1. **Diálogos Mono/Gecko bloquean la creación** → se crea con `WINEDLLOVERRIDES="mscoree,mshtml="`
2. **dotnet48 deja el prefix en Windows 7** → el script lo restaura a Windows 10 automáticamente
3. **Apps corren pero sin ventana visible** (BadWindow) → driver Wayland de Wine 11; se fija x11
4. **Checksums desactualizados en winetricks** → se actualiza winetricks antes de todo
5. **Prefixes win32 antiguos no arrancan con Wine 11** → los builds nuevos son WoW64-only; este repo usa win64 desde el inicio

## Uso diario

```bash
# Abrir el escritorio Windows (o desde el menú de aplicaciones)
wine explorer /desktop=shell,1600x900

# Instalar una aplicación
wine ruta/al/instalador.exe

# Utilidades
wine cmd          # terminal CMD
wine control      # Panel de Control
wine uninstaller  # Agregar/quitar programas
winecfg           # configuración (overrides por app aquí)
```

Las apps instaladas crean su propia entrada en el menú de aplicaciones de tu escritorio Linux.

## Restaurar la imagen de fábrica

```bash
rm -rf ~/.wine && tar -xzf ~/wine-backups/wine-prefix-dorado-*.tar.gz -C ~
```

## Documentación adicional

- [Solución de problemas](docs/SOLUCION-PROBLEMAS.md) — diagnóstico de ventanas invisibles, fuentes, rendimiento
- [Apéndice experimental](docs/EXPERIMENTAL.md) — shells alternativos (RetroBar), temas msstyles

## Licencia

MIT — ver [LICENSE](LICENSE).

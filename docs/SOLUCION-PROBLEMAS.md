# Solución de problemas

## La ventana del escritorio se ve negra cuando NO tiene el foco

Problema conocido de Wine bajo XWayland con compositores Wayland (reportado en
KDE, GNOME y Sway): la ventana deja de repintarse al perder el foco. Es
**cosmético** — el contenido vuelve al enfocarla de nuevo.

Mitigaciones:
1. Cerrar otras ventanas Wine huérfanas: `wineserver -k` y reabrir el escritorio
2. Si te molesta a diario: iniciar sesión en **"Plasma (X11)"** desde la pantalla
   de login — bajo Xorg el problema no existe
3. Verificar que el efecto KWin "Atenuar ventanas inactivas" esté desactivado
   (Preferencias del sistema → Efectos de escritorio)

## El menú Inicio abre las apps con error "Archivo no encontrado"

Los `.lnk` fueron creados con una herramienta externa que el shell de Wine no
puede resolver. Regenerarlos con el shell nativo: `./scripts/08-menu-inicio.sh`
(crea los accesos vía shell32 de Wine, que sí resuelven).

## "Salir" del menú Inicio no cierra el entorno

Limitación conocida del explorer de Wine. Alternativas confiables:
1. Menú Inicio → Programs → Accesorios → **"Apagar Windows"** (creado por el paso 08)
2. El botón X de la ventana
3. Terminal: `wineserver -k`

## La app corre pero no aparece ninguna ventana

**Síntoma:** `pgrep` muestra el proceso vivo, pero no hay ventana. Con escritorio
virtual puede aparecer `X Error: BadWindow (X_CreateWindow)`.

**Causa:** Wine 11 usa su driver Wayland nativo por defecto. En algunas sesiones
(KDE Wayland especialmente) falla la creación de ventanas, y el modo escritorio
virtual no está soportado en ese driver.

**Solución:**
```bash
wine reg add "HKCU\\Software\\Wine\\Drivers" /v Graphics /t REG_SZ /d "x11" /f
wineserver -k
```

**Cómo validar de verdad:** no basta con que el proceso exista.
```bash
wmctrl -l | grep -i "wine desktop"   # debe listar la ventana
```

## El instalador dice que mi Windows es demasiado nuevo/viejo

No cambies la versión global. Usa overrides por aplicación:
`winecfg` → pestaña **Aplicaciones** → **Agregar aplicación** → seleccionar el
`.exe` → elegir su versión de Windows (y sus librerías en la pestaña Librerías).

## dotnet48 falla o el prefix quedó "raro" después

1. El verbo cambia el prefix a Windows 7 y lo deja así → `winetricks win10`
2. Si falla la descarga: `rm -rf ~/.cache/winetricks/dotnet48` y reintentar
3. Si falla repetidamente: actualizar winetricks (`echo Y | sudo winetricks --self-update`)

## Error "is a 32-bit installation, it cannot support 64-bit applications"

Tienes un prefix win32 creado con un Wine antiguo. Los builds modernos de WineHQ
son WoW64-only y **no pueden usar prefixes win32 antiguos**. No hay conversión:
crea un prefix win64 nuevo (estos scripts) y reinstala las apps. El win64 corre
aplicaciones de 32 bits sin problema.

## La zona alrededor del explorador se ve negra al abrir el escritorio

Artefacto cosmético del primer pintado en XWayland. Desaparece al mover o
redimensionar cualquier ventana. No afecta el funcionamiento.

## Fuentes borrosas o feas

```bash
winetricks -q fontsmooth=rgb     # ClearType subpíxel
```
Si tu panel es BGR: `fontsmooth=bgr`.

## Quiero deshacer todo

```bash
./scripts/99-backup.sh restaurar    # vuelve a la imagen de fábrica
# o eliminación total:
rm -rf ~/.wine
```

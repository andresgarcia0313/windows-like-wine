# Solución de problemas

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

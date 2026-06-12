#!/usr/bin/env bash
# 05 - Mejoras visuales: driver estable, escritorio con taskbar, ClearType, fuentes.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all

echo "==> Forzando driver gráfico x11 (XWayland)..."
# Wine 11 usa el driver Wayland nativo por defecto; en KDE Wayland falla la
# creación de ventanas (BadWindow) y el escritorio virtual no está soportado.
wine reg add "HKCU\\Software\\Wine\\Drivers" /v Graphics /t REG_SZ /d "x11" /f

echo "==> Activando escritorio virtual 'shell' (taskbar + menú inicio)..."
# El nombre "shell" es especial: el explorer de Wine muestra barra de tareas
# con botón de inicio, lista de ventanas y reloj.
wine reg add "HKCU\\Software\\Wine\\Explorer" /v Desktop /t REG_SZ /d shell /f
wine reg add "HKCU\\Software\\Wine\\Explorer\\Desktops" /v shell /t REG_SZ /d 1600x900 /f

echo "==> Suavizado de fuentes ClearType (subpíxel RGB)..."
winetricks -q fontsmooth=rgb

echo "==> Sustitución Segoe UI -> Tahoma..."
# Windows 10 usa Segoe UI (no existe en Wine). Sin esta sustitución muchas
# apps modernas muestran fuentes incorrectas o cuadros vacíos.
wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes" \
  /v "Segoe UI" /t REG_SZ /d Tahoma /f

echo "==> Verificación:"
wine reg query "HKCU\\Software\\Wine\\Drivers" /v Graphics | grep x11
wine reg query "HKCU\\Software\\Wine\\Explorer" /v Desktop | grep shell
echo "OK: paso 05 completado."

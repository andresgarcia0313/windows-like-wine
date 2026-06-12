#!/usr/bin/env bash
# 03 - Instala los runtimes que un Windows 10 real trae (orden probado).
# IMPORTANTE: nunca ejecutar dos winetricks a la vez sobre el mismo prefix.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all

echo "==> Fuentes (corefonts + tahoma, usada por diálogos de muchas apps)..."
winetricks -q corefonts tahoma

echo "==> Visual C++ Redistributables 2005-2022..."
# vcrun2022 incluye los runtimes unificados 2015/2017/2019.
winetricks -q vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2022

echo "==> XML, texto enriquecido y GDI+..."
winetricks -q msxml3 msxml6 riched20 riched30 gdiplus

echo "==> Verificación (DLLs en ambas arquitecturas):"
ls "$WINEPREFIX/drive_c/windows/system32/msvcp140.dll" \
   "$WINEPREFIX/drive_c/windows/syswow64/msvcp140.dll"
echo "Fuentes instaladas: $(ls "$WINEPREFIX/drive_c/windows/Fonts/" | wc -l)"
echo "OK: paso 03 completado."

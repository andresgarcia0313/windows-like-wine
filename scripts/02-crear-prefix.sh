#!/usr/bin/env bash
# 02 - Crea el prefix maestro win64 y lo configura como Windows 10.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all

if [ -d "$WINEPREFIX" ]; then
  echo "AVISO: $WINEPREFIX ya existe. Borra o exporta otro WINEPREFIX si quieres recrear."
  exit 1
fi

echo "==> Creando prefix win64 en $WINEPREFIX ..."
# mscoree/mshtml deshabilitados SOLO durante la creación: evita los diálogos
# de Wine Mono y Gecko que bloquean la ejecución desatendida.
# .NET real se instala después (paso 04) y reemplaza a Mono de todas formas.
WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init
wineserver -w

echo "==> Configurando Windows 10 como versión global..."
winetricks win10

echo "==> Verificación:"
grep '#arch' "$WINEPREFIX/system.reg" | head -1
wine cmd /c ver 2>/dev/null | tr -d '\r' | grep -v '^$'
echo "OK: paso 02 completado."

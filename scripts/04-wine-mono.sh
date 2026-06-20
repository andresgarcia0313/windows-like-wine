#!/usr/bin/env bash
# 04-wine-mono.sh - Base .NET del entorno: Wine Mono (reemplazo libre de .NET
# Framework hasta 4.8.1). Es el metodo RECOMENDADO; sustituye al enfoque
# dotnet48 (ver 04-dotnet48.sh, ahora alternativa OPCIONAL).
#
# Por que Wine Mono y no el .NET Framework real de Microsoft:
#   - El prefix es win64; "winetricks dotnet48" es notoriamente fragil en 64-bit
#     (instalador roto, "Failed to open RpcSs service", conflictos de registro).
#   - Wine Mono se instala limpio via .msi oficial, cubre .NET Framework <=4.8.1
#     y coexiste con .NET Core / .NET 5+. Falla mucho menos para uso general.
#   - dotnet48 real queda SOLO para una app concreta que falle con Mono, y NUNCA
#     junto a Wine Mono (la serie 4.x es mutuamente excluyente).
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all

VER="11.2.0"                       # ultima estable a 2026-06-20 (wine-mono/wine-mono)
MSI="wine-mono-${VER}-x86.msi"     # un solo .msi sirve para x86 y x86_64
URL="https://github.com/wine-mono/wine-mono/releases/download/wine-mono-${VER}/${MSI}"
SIZE_OK=83324416                   # bytes exactos del asset oficial (anti-corrupcion)
CACHE="$HOME/.cache/wine"

echo "==> Descargando ${MSI} (oficial, a cache de Wine)..."
mkdir -p "$CACHE"
if [ ! -s "$CACHE/$MSI" ] || [ "$(stat -c%s "$CACHE/$MSI")" != "$SIZE_OK" ]; then
  curl -sL -o "$CACHE/$MSI" "$URL"
fi
SZ="$(stat -c%s "$CACHE/$MSI")"
[ "$SZ" = "$SIZE_OK" ] || { echo "ERROR: tamano $SZ != $SIZE_OK (descarga corrupta)"; exit 1; }

echo "==> Instalando Wine Mono ${VER} (idempotente; /qn desatendido)..."
wine msiexec /i "$CACHE/$MSI" /qn
wineserver -w

echo "==> Validacion:"
ls "$WINEPREFIX/drive_c/windows/mono/mono-2.0/"*.dll >/dev/null && echo "   mono-2.0 OK"
ls "$WINEPREFIX/drive_c/windows/system32/mscoree.dll" \
   "$WINEPREFIX/drive_c/windows/syswow64/mscoree.dll" >/dev/null && echo "   mscoree (dual-arch) OK"
echo "OK: paso 04 (Wine Mono ${VER}) completado."

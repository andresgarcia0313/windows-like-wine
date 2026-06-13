#!/usr/bin/env bash
# 09 - Tuning avanzado: NTSYNC, Gecko, capa gráfica, runtimes empresariales y pulido.
# Requiere kernel 6.14+ (NTSYNC) y GPU con Vulkan 1.3+ (DXVK).
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all

echo "==> 1/6 NTSYNC (sincronización NT en kernel, Wine 11+)..."
sudo modprobe ntsync
echo "ntsync" | sudo tee /etc/modules-load.d/ntsync.conf >/dev/null
# Validación empírica: algunos builds de Wine vienen SIN soporte ntsync.
wine winemine >/dev/null 2>&1 & sleep 5
if [ -n "$(lsof /dev/ntsync 2>/dev/null)" ]; then echo "   NTSYNC: Wine lo usa"; else
  echo "   AVISO: este build de Wine no usa ntsync (compilado sin soporte)"; fi
wineserver -k 2>/dev/null || true

echo "==> 2/6 Wine Gecko 2.47.4 (HTML embebido; AMBAS arquitecturas)..."
TMP="$(mktemp -d)"
for arch in x86 x86_64; do
  # OJO: el nombre usa guion (wine-gecko-...), no guion bajo.
  curl -sL -o "$TMP/g-$arch.msi" \
    "https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-$arch.msi"
  file "$TMP/g-$arch.msi" | grep -q "Composite Document" || { echo "ERROR descarga $arch"; exit 1; }
  wine msiexec /i "$TMP/g-$arch.msi" /qn
done
rm -rf "$TMP"

echo "==> 3/6 Capa gráfica (DXVK requiere Vulkan 1.3+; verificando)..."
vulkaninfo --summary 2>/dev/null | grep -q "apiVersion *= *1\.[3-9]" \
  || { echo "ERROR: GPU sin Vulkan 1.3+; omitir DXVK"; exit 1; }
winetricks -q dxvk vkd3d d3dx9 d3dcompiler_47

echo "==> 4/6 Runtimes empresariales..."
winetricks -q vb6run   # Visual Basic 6 (el verbo es vb6run, NO vbrun6)
# mdac28/jet40 NO funcionan en prefixes win64 (límite de winetricks).
# Si una app pide Jet/ODBC legacy: instalar Access Database Engine (ACE) per-app.

echo "==> 5/6 Pulido..."
winetricks -q nocrashdialog
wine reg add "HKCU\\Software\\Wine\\Direct3D" /v VideoMemorySize /t REG_SZ /d 4096 /f
# allfonts es opcional (pesado, mayormente fuentes CJK): winetricks -q allfonts

echo "==> 6/6 Verificación final..."
wine cmd /c ver 2>/dev/null | tr -d '\r' | grep -v '^$'
strings "$WINEPREFIX/drive_c/windows/system32/d3d11.dll" | grep -qi dxvk && echo "   DXVK activo"
ls "$WINEPREFIX/drive_c/windows/system32/gecko/2.47.4" >/dev/null && echo "   Gecko OK"
ls "$WINEPREFIX/drive_c/windows/syswow64/msvbvm60.dll" >/dev/null && echo "   VB6 OK"
echo "OK: paso 09 completado. Recomendado: regenerar backup (99-backup.sh)."

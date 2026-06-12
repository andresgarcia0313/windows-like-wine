#!/usr/bin/env bash
# 07 - Instala las apps básicas de Windows que Wine no incluye: Calculadora y Paint.
#
# Contexto: Wine ya trae notepad, write (WordPad), taskmgr, regedit, cmd,
# control, explorer, msinfo32 y winver como reimplementaciones libres.
# Las versiones MODERNAS (UWP) de Calculadora/Paint no funcionan en Wine.
# Las versiones clásicas (era XP, Win32 puro) funcionan perfecto y se
# descargan de Internet Archive para uso personal.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all
SYS32="$WINEPREFIX/drive_c/windows/system32"
TMP="$(mktemp -d)"

echo "==> Dependencia de Paint: MFC42 (sin ella Paint muere en silencio)..."
winetricks -q mfc42

echo "==> Descargando Calculadora clásica (114 KB, con modo científico)..."
curl -sL -o "$TMP/calc.exe" \
  "https://archive.org/download/calc_exe_windows_xp/calc.exe"
file "$TMP/calc.exe" | grep -q "PE32" || { echo "ERROR: descarga inválida"; exit 1; }
cp "$TMP/calc.exe" "$SYS32/"

echo "==> Descargando Paint clásico (335 KB)..."
curl -sL -o "$TMP/mspaint.exe" \
  "https://archive.org/download/mspaint_xp_version/mspaint.exe"
file "$TMP/mspaint.exe" | grep -q "PE32" || { echo "ERROR: descarga inválida"; exit 1; }
cp "$TMP/mspaint.exe" "$SYS32/"

echo "==> Verificación (los procesos deben sobrevivir 5 segundos):"
for app in calc mspaint; do
  wine "$app" >/dev/null 2>&1 &
  PID=$!
  sleep 5
  kill -0 "$PID" 2>/dev/null && echo "  $app: OK" || echo "  $app: FALLO"
  wineserver -k 2>/dev/null || true
  sleep 1
done
rm -rf "$TMP"
echo "OK: paso 07 completado. Uso: wine calc | wine mspaint"

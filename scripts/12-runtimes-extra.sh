#!/usr/bin/env bash
# 12 - Runtimes por demanda: amplian la compatibilidad del windows-like con
# multimedia, fisica, audio de juegos, apps .NET modernas y D3D12 al dia.
# Idempotente (winetricks salta lo ya instalado). Cada verbo es NO fatal: si uno
# no aplica en prefix win64 se avisa y se continua, sin abortar el resto.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all

try() {
  echo "==> $*"
  winetricks -q "$@" || echo "   AVISO: '$*' fallo o no aplica en win64 (continuo)"
}

echo "== Runtimes por demanda =="
echo "-- 1/5 Multimedia DirectShow (quartz: reproduccion de video/audio en apps) --"
try quartz

echo "-- 2/5 NVIDIA PhysX (fisica en juegos) --"
try physx

echo "-- 3/5 Audio de juegos (XACT / XAudio2, 32 y 64 bits) --"
try xact xact_x64

echo "-- 4/5 .NET Desktop Runtime 8 (apps .NET modernas framework-dependent) --"
# Complementa wlbuild: ejecuta apps net8 que NO son self-contained.
try dotnetdesktop8

echo "-- 5/5 vkd3d-proton al dia (Direct3D 12 -> Vulkan) --"
try vkd3d

echo "== Verificacion =="
SYS="$WINEPREFIX/drive_c/windows/system32"
[ -f "$SYS/quartz.dll" ]      && echo "   quartz OK"
[ -f "$SYS/xactengine3_7.dll" ] && echo "   xact OK"
[ -f "$SYS/d3d12.dll" ]       && echo "   d3d12/vkd3d OK"
echo "OK: paso 12 completado. Recomendado: regenerar backup (99-backup.sh)."

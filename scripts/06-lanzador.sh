#!/usr/bin/env bash
# 06 - Instala el lanzador "Windows 10 (Wine)" en el menú de aplicaciones.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.local/share/applications/windows10-wine.desktop"

echo "==> Instalando lanzador..."
mkdir -p "$HOME/.local/share/applications"
cp "$REPO_DIR/launcher/windows10-wine.desktop" "$DEST"

echo "==> Validando formato..."
desktop-file-validate "$DEST"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "==> Prueba real (la ventana debe aparecer; se cierra sola en 10 s)..."
gio launch "$DEST" || true
sleep 8
if wmctrl -l | grep -qi "wine desktop"; then
  echo "VALIDADO: ventana 'Wine Desktop' visible."
  wineserver -k || true
else
  echo "AVISO: no se detectó la ventana. Revisa docs/SOLUCION-PROBLEMAS.md"
fi
echo "OK: paso 06 completado. Busca 'Windows 10 (Wine)' en tu menú."

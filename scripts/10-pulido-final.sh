#!/usr/bin/env bash
# 10 - Pulido final: rendimiento host, DPI, color, resolución, sandbox y WMP.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all

echo "==> 1/7 Reducir swappiness del host (menos swap = menos latencia)..."
# El default de algunos kernels es 60-150; 10 es ideal para desktop con 8+GB RAM.
sudo sysctl vm.swappiness=10
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null

echo "==> 2/7 DPI (96 para 1080p, 120 para 1440p, 144 para 4K)..."
# Detectar y sugerir:
RES=$(xrandr 2>/dev/null | grep '\*' | head -1 | awk '{print $1}')
case "$RES" in
  3840*) DPI=144 ;; 2560*) DPI=120 ;; *) DPI=96 ;;
esac
wine reg add "HKCU\\Control Panel\\Desktop" /v LogPixels /t REG_DWORD /d "$DPI" /f
echo "   DPI=$DPI para resolución $RES"

echo "==> 3/7 Color de fondo azul Windows 10..."
wine reg add "HKCU\\Control Panel\\Colors" /v Background /t REG_SZ /d "30 60 120" /f

echo "==> 4/7 Resolución del escritorio virtual = pantalla real..."
wine reg add "HKCU\\Software\\Wine\\Explorer\\Desktops" /v shell /t REG_SZ /d "$RES" /f
# Actualizar lanzador si existe:
DESKTOP_FILE="$HOME/.local/share/applications/windows10-wine.desktop"
[ -f "$DESKTOP_FILE" ] && sed -i "s|/desktop=shell,[0-9x]*|/desktop=shell,$RES|" "$DESKTOP_FILE"
echo "   Escritorio=$RES"

echo "==> 5/7 Verificar clipboard (X11/XWayland lo comparte automáticamente)..."
command -v xclip >/dev/null || sudo apt install -y xclip
echo "test-wine-clipboard" | xclip -selection clipboard
xclip -selection clipboard -o >/dev/null && echo "   Clipboard: OK"

echo "==> 6/7 Sandbox: aislar prefix de la raíz del host..."
# Z: apunta a / — los instaladores pueden leer/escribir tu Linux.
rm -f "$WINEPREFIX/dosdevices/z:"
# winemenubuilder crea entradas .desktop en KDE por cada app instalada.
# Desactivarlo evita contaminación del menú del host.
wine reg add "HKCU\\Software\\Wine\\DllOverrides" \
  /v winemenubuilder.exe /t REG_SZ /d "" /f
echo "   Z: eliminado, winemenubuilder desactivado"

echo "==> 7/7 Windows Media Player 11 (audio/video embebido)..."
winetricks -q wmp11 || echo "   AVISO: wmp11 falló (no crítico)"

echo "OK: paso 10 completado. Recomendado: regenerar backup (99-backup.sh)."

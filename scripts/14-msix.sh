#!/usr/bin/env bash
# 14 - Instala 'wl-msix' (soporte Nivel 0 de apps MSIX/AppX Win32) en el PATH.
#
# wl-msix no toca el prefix: extrae el MSIX (ZIP/OPC), lee su AppxManifest y lanza
# el .exe Win32 del paquete. Las apps WinUI3/AppContainer quedan fuera de alcance
# (se diagnostican, no se fuerzan). Ver proyectos/soporte-uwp/ para el detalle.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$HOME/.local/bin"

echo "==> Verificando dependencias..."
command -v python3 >/dev/null || { echo "ERROR: falta python3"; exit 1; }
command -v wine    >/dev/null || { echo "ERROR: falta wine"; exit 1; }

echo "==> Enlazando wl-msix en $BIN..."
mkdir -p "$BIN"
ln -sf "$REPO_DIR/bin/wl-msix" "$BIN/wl-msix"
chmod +x "$REPO_DIR/bin/wl-msix" "$REPO_DIR/tools/"msix_*.py

echo "==> Prueba real end-to-end (genera un MSIX de muestra y valida el ciclo)..."
if command -v dotnet >/dev/null; then
  "$REPO_DIR/proyectos/soporte-uwp/tests/test-nivel0.sh" \
    && echo "VALIDADO: ciclo install/launch/remove correcto." \
    || { echo "ERROR: la validacion fallo"; exit 1; }
else
  echo "AVISO: sin dotnet en el host; se omite la prueba (wl-msix queda instalado)."
fi
echo "OK: paso 14 completado. Uso: wl-msix install <pkg.msix> && wl-msix launch <AppId>"

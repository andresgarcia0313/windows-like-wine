#!/usr/bin/env bash
# Valida el Nivel 0 de wl-msix end-to-end con un MSIX de muestra generado.
# Criterio de exito global: 0 fallas. Codigo de salida != 0 si algo falla.
set -uo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../../.." && pwd)"
WLMSIX="$REPO/bin/wl-msix"
ID="HelloMsix.Sample"
pass=0; fail=0
ok() { echo "  [OK] $1"; pass=$((pass+1)); }
no() { echo "  [FALLA] $1"; fail=$((fail+1)); }

echo "== 1. Generar MSIX de muestra =="
MSIX="$("$HERE/make-sample-msix.sh")" && [ -f "$MSIX" ] && ok "MSIX generado: $MSIX" || { no "no se genero el MSIX"; exit 1; }

echo "== 2. info (clasificacion Win32) =="
"$WLMSIX" info "$MSIX" | grep -q '"class": "win32"' && ok "clasificada Win32" || no "no clasifico Win32"

echo "== 3. install =="
"$WLMSIX" install "$MSIX" >/dev/null
[ -d "$WINEPREFIX/drive_c/msix/$ID" ] && ok "payload instalado" || no "sin payload instalado"

echo "== 4. list =="
"$WLMSIX" list | grep -q "$ID" && ok "aparece en list" || no "no aparece en list"

echo "== 5. launch (espera marcador WL-MSIX-OK) =="
OUTPUT="$("$WLMSIX" launch "$ID" 2>/dev/null | tr -d '\r')"
echo "$OUTPUT" | grep -q "WL-MSIX-OK" && ok "el .exe Win32 corrio en Wine" || no "no corrio (salida: '$OUTPUT')"
wineserver -k 2>/dev/null || true

echo "== 6. remove (sin residuos) =="
"$WLMSIX" remove "$ID" >/dev/null
[ ! -d "$WINEPREFIX/drive_c/msix/$ID" ] && ok "payload eliminado" || no "quedo residuo de payload"
"$WLMSIX" list | grep -q "$ID" && no "sigue en el index" || ok "fuera del index"

echo "== RESUMEN: $pass OK, $fail FALLAS =="
[ "$fail" -eq 0 ]

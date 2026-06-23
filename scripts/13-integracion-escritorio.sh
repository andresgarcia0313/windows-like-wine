#!/usr/bin/env bash
# 13 - Integracion de escritorio: que los dialogos Abrir/Guardar de las apps
# Windows naveguen los archivos REALES del host (carpetas XDG) y que el prefix
# tenga mas cobertura tipografica (Liberation, DejaVu, Noto + emoji a color).
# Idempotente: re-enlaza solo lo que apunte mal y salta fuentes ya instaladas.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all
USERDIR="$WINEPREFIX/drive_c/users/$USER"
FONTS="$WINEPREFIX/drive_c/windows/Fonts"

echo "== Integracion de escritorio =="

echo "-- 1/2 Acceso a archivos reales (carpetas XDG del host) --"
# Mapea cada carpeta de shell del usuario Windows a su equivalente XDG real, asi
# el file picker de Wine muestra los archivos del usuario en vez de carpetas vacias.
link_xdg() {
  local win_name="$1" xdg_key="$2"; shift 2  # resto = carpetas candidatas de respaldo
  local target
  target="$(xdg-user-dir "$xdg_key" 2>/dev/null || true)"
  target="${target%/}"  # normaliza barra final (xdg a veces devuelve "$HOME/")
  # Si XDG no da una carpeta propia (vacio o el home pelado), probar respaldos
  # localizados (ej ~/Musica) para no exponer todo el home en el dialogo.
  if [ -z "$target" ] || [ "$target" = "$HOME" ] || [ ! -d "$target" ]; then
    target=""
    local c
    for c in "$@"; do [ -d "$HOME/$c" ] && { target="$HOME/$c"; break; }; done
  fi
  [ -n "$target" ] || { echo "   omito $win_name (sin carpeta XDG valida)"; return 0; }
  if [ "$(readlink -f "$USERDIR/$win_name" 2>/dev/null)" = "$target" ]; then
    echo "   $win_name OK -> $target"
  else
    rm -rf "$USERDIR/$win_name"
    ln -s "$target" "$USERDIR/$win_name"
    echo "   $win_name re-enlazado -> $target"
  fi
}
link_xdg Desktop   DESKTOP   Escritorio Desktop
link_xdg Documents DOCUMENTS Documentos Documents
link_xdg Downloads DOWNLOAD  Descargas Downloads
link_xdg Music     MUSIC     "Música" Musica Music
link_xdg Pictures  PICTURES  "Imágenes" Imagenes Pictures
link_xdg Videos    VIDEOS    "Vídeos" Videos

echo "-- 2/2 Fuentes adicionales (cobertura Unicode + emoji a color) --"
# Curado: NO se fuerza sustitucion (corefonts ya aporta Arial/Times/Courier).
# Solo se suman familias libres para que mas apps rendericen texto y simbolos.
declare -A WANT=(
  [LiberationSans-Regular.ttf]=truetype/liberation
  [LiberationSerif-Regular.ttf]=truetype/liberation
  [LiberationMono-Regular.ttf]=truetype/liberation
  [DejaVuSans.ttf]=truetype/dejavu
  [DejaVuSansMono.ttf]=truetype/dejavu
  [NotoSans-Regular.ttf]=truetype/noto
  [NotoColorEmoji.ttf]=truetype/noto
)
nuevas=0
for f in "${!WANT[@]}"; do
  src="/usr/share/fonts/${WANT[$f]}/$f"
  [ -f "$src" ] || { echo "   AVISO: no esta en el host: $f"; continue; }
  if [ -f "$FONTS/$f" ]; then
    echo "   ya instalada: $f"; continue
  fi
  cp "$src" "$FONTS/$f"
  wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" \
    /v "${f%.ttf} (TrueType)" /t REG_SZ /d "$f" /f 2>/dev/null \
    && { echo "   + $f"; nuevas=$((nuevas+1)); }
done
echo "   fuentes nuevas registradas: $nuevas"

echo "== Verificacion =="
ls -l "$USERDIR/Music" 2>/dev/null | sed 's/^/   /'
echo "   fuentes en el prefix: $(ls "$FONTS" | wc -l)"
echo "OK: paso 13 completado."

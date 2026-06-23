#!/usr/bin/env bash
# fetch-sources.sh — soberania del codigo fuente del windows-like.
# Descarga y CONGELA el source de cada componente opensource (ver sources.lock),
# verificando su integridad. Asi el entorno se reconstruye sin depender de los
# servidores de terceros. Idempotente.
#
# Uso:
#   vendor/fetch-sources.sh                 # descarga y verifica contra sources.lock
#   vendor/fetch-sources.sh --record        # primera vez: registra los hashes reales
#   vendor/fetch-sources.sh --mirror DIR    # copia los sources congelados a DIR (Canvio)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
LOCK="$HERE/sources.lock"
CACHE="$HERE/cache"
RECORD=0 ; MIRROR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --record) RECORD=1; shift ;;
    --mirror) MIRROR="${2:-}"; shift 2 ;;
    *) echo "opcion desconocida: $1" >&2; exit 1 ;;
  esac
done
mkdir -p "$CACHE"

set_hash() {  # actualiza el campo hash de un componente en sources.lock
  local name="$1" h="$2"
  awk -F'|' -v n="$name" -v h="$h" 'BEGIN{OFS="|"}
    /^#/||NF<7{print;next} $1==n{$5=h} {print}' "$LOCK" >"$LOCK.tmp" && mv "$LOCK.tmp" "$LOCK"
}

while IFS='|' read -r name type version url hash lic redist; do
  case "$name" in ''|\#*) continue ;; esac
  echo "==> $name ($type $version)"
  if [ "$type" = "tar" ]; then
    f="$CACHE/$(basename "$url")"
    [ -f "$f" ] || curl -fL --retry 3 -o "$f" "$url"
    real="$(sha256sum "$f" | cut -d' ' -f1)"
    if [ "$RECORD" = 1 ] || [ "$hash" = PENDIENTE ]; then
      set_hash "$name" "$real"; echo "   sha256 registrado: $real"
    elif [ "$real" != "$hash" ]; then
      echo "   ERROR: sha256 NO coincide (upstream cambio?). esperado $hash, real $real" >&2; exit 1
    else echo "   sha256 OK"; fi
  else  # git: clona/actualiza a tag o rama y congela el commit
    d="$CACHE/$name"
    if [ -d "$d/.git" ]; then git -C "$d" fetch -q --tags origin
    else git clone -q "$url" "$d"; fi
    [ "$version" = HEAD ] || git -C "$d" checkout -q "$version"
    commit="$(git -C "$d" rev-parse HEAD)"
    if [ "$RECORD" = 1 ] || [ "$hash" = PENDIENTE ]; then
      set_hash "$name" "$commit"; echo "   commit registrado: $commit"
    elif [ "$commit" != "$hash" ]; then
      echo "   AVISO: commit actual $commit != congelado $hash (rama movio)" >&2
    else echo "   commit OK"; fi
  fi
done <"$LOCK"

if [ -n "$MIRROR" ]; then
  echo "==> Copiando sources congelados a $MIRROR"
  mkdir -p "$MIRROR"; cp -a "$CACHE/." "$MIRROR/"
  echo "   copia fria lista en $MIRROR"
fi
echo "OK: fuentes congeladas en $CACHE (manifiesto: $LOCK)"

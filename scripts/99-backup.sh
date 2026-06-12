#!/usr/bin/env bash
# 99 - Crea (o restaura) la "imagen de fábrica" del prefix.
# Uso:  ./99-backup.sh           -> crear backup
#       ./99-backup.sh restaurar -> restaurar el más reciente
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
BACKUP_DIR="$HOME/wine-backups"

if [ "${1:-}" = "restaurar" ]; then
  ULTIMO="$(ls -t "$BACKUP_DIR"/wine-prefix-dorado-*.tar.gz 2>/dev/null | head -1)"
  [ -n "$ULTIMO" ] || { echo "No hay backups en $BACKUP_DIR"; exit 1; }
  echo "==> Restaurando: $ULTIMO"
  read -rp "Esto BORRA $WINEPREFIX actual. ¿Continuar? [s/N] " R
  [ "$R" = "s" ] || exit 0
  wineserver -k 2>/dev/null || true
  rm -rf "$WINEPREFIX"
  tar -xzf "$ULTIMO" -C "$HOME"
  echo "OK: prefix restaurado."
else
  echo "==> Creando backup dorado (puede tardar ~2 min)..."
  wineserver -k 2>/dev/null || true
  sleep 2
  mkdir -p "$BACKUP_DIR"
  tar -czf "$BACKUP_DIR/wine-prefix-dorado-$(date +%Y%m%d).tar.gz" -C "$HOME" .wine
  ls -lh "$BACKUP_DIR" | tail -1
  echo "OK: backup creado en $BACKUP_DIR"
fi

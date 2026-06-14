#!/usr/bin/env bash
# 11 - Upgrade visual: fuentes Segoe UI reales, charmap y tema Win10 msstyles.
# Requiere acceso SSH al PC Windows (para Segoe UI y charmap) O archivos locales.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all
FONTS_DIR="$WINEPREFIX/drive_c/windows/Fonts"
SYS32="$WINEPREFIX/drive_c/windows/system32"

echo "==> 1/3 Fuentes Segoe UI..."
if [ -d "${1:-/tmp/segoe-fonts}" ] && ls "${1:-/tmp/segoe-fonts}"/*.ttf >/dev/null 2>&1; then
  cp "${1:-/tmp/segoe-fonts}"/*.ttf "$FONTS_DIR/"
  # Registrar cada fuente en el registro
  for f in "$FONTS_DIR"/segoe*.ttf "$FONTS_DIR"/Segoe*.ttf; do
    NAME="$(basename "$f")"
    wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" \
      /v "$NAME (TrueType)" /t REG_SZ /d "$NAME" /f 2>/dev/null
  done
  # Eliminar sustitución Segoe UI→Tahoma (ya tenemos la real)
  wine reg delete "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes" \
    /v "Segoe UI" /f 2>/dev/null || true
  echo "   $(ls "$FONTS_DIR"/segoe*.ttf "$FONTS_DIR"/Segoe*.ttf 2>/dev/null | wc -l) fuentes Segoe instaladas"
else
  echo "   AVISO: no se encontraron fuentes Segoe UI en ${1:-/tmp/segoe-fonts}/"
  echo "   Copiar desde un Windows real: scp user@host:'C:/Windows/Fonts/segoe*' /tmp/segoe-fonts/"
fi

echo "==> 2/3 Charmap (mapa de caracteres)..."
if [ -f "${2:-/tmp/charmap.exe}" ]; then
  cp "${2:-/tmp/charmap.exe}" "$SYS32/"
  # Crear acceso en menú Inicio si CreateLnk.exe existe
  if [ -f "$WINEPREFIX/drive_c/users/Public/CreateLnk.exe" ]; then
    wine 'C:\users\Public\CreateLnk.exe' \
      "C:\\users\\$USER\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Accesorios\\Mapa de caracteres.lnk" \
      "C:\\windows\\system32\\charmap.exe" 2>/dev/null | tr -d '\r'
  fi
  echo "   charmap instalado"
else
  echo "   AVISO: charmap.exe no encontrado. Copiar desde Windows: scp user@host:'C:/Windows/System32/charmap.exe' /tmp/"
fi

echo "==> 3/3 Tema Windows 10 (Botspot/wine-stuff)..."
THEME_DIR="$WINEPREFIX/drive_c/windows/resources/themes/windows10"
mkdir -p "$THEME_DIR"
if [ ! -f "$THEME_DIR/windows10.msstyles" ]; then
  curl -sL -o "$THEME_DIR/windows10.msstyles" \
    "https://github.com/Botspot/wine-stuff/raw/main/Windows_10.msstyles"
fi
wine reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ThemeManager" \
  /v DllName /t REG_SZ /d "C:\\windows\\resources\\themes\\windows10\\windows10.msstyles" /f
wine reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ThemeManager" \
  /v ColorName /t REG_SZ /d "NormalColor" /f
wine reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ThemeManager" \
  /v SizeName /t REG_SZ /d "NormalSize" /f
echo "   tema windows10.msstyles activo"

echo "OK: paso 11 completado. Fuentes: $(ls "$FONTS_DIR" | wc -l) | Menú: $(ls "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Accesorios/" 2>/dev/null | wc -l) accesos"

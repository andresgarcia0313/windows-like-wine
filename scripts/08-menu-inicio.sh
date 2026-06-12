#!/usr/bin/env bash
# 08 - Crea los accesos del menú Inicio (Accesorios) + "Apagar Windows".
# Requiere el paso 04 (.NET 4.8) porque compila una mini-herramienta C#.
#
# Por qué así: el VBScript de Wine NO implementa CreateShortcut (no-op
# silencioso) y los .lnk generados por herramientas externas (pylnk3) no
# resuelven en el shell de Wine ("Archivo no encontrado"). La vía confiable
# es crear los .lnk con el PROPIO shell32 de Wine (IShellLink+IPersistFile),
# vía una herramienta C# de 50 líneas compilada con el csc del prefix.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CSC='C:\windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'

echo "==> Compilando CreateLnk.exe con el csc del prefix..."
cp "$REPO_DIR/tools/CreateLnk.cs" /tmp/CreateLnk.cs
wine "$CSC" /nologo /out:'C:\users\Public\CreateLnk.exe' 'Z:\tmp\CreateLnk.cs'

BASE="C:\\users\\$USER\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Accesorios"
mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Accesorios"

echo "==> Generando accesos directos..."
mk() { wine 'C:\users\Public\CreateLnk.exe' "$BASE\\$1.lnk" "$2" ${3:+"$3"} | tr -d '\r'; }
mk "Calculadora"             'C:\windows\system32\calc.exe'
mk "Paint"                   'C:\windows\system32\mspaint.exe'
mk "Bloc de notas"           'C:\windows\system32\notepad.exe'
mk "WordPad"                 'C:\windows\system32\write.exe'
mk "Administrador de tareas" 'C:\windows\system32\taskmgr.exe'
# Salir del entorno de forma confiable (el Exit del menú no siempre cierra):
mk "Apagar Windows"          'C:\windows\system32\wineboot.exe' '-k'

echo "==> Verificación: el .lnk debe abrir la app sin 'Archivo no encontrado'..."
wine start "$BASE\\Calculadora.lnk" 2>&1 | grep -i "no encontrado" \
  && { echo "ERROR: el lnk no resuelve"; exit 1; } || true
sleep 4
wineserver -k 2>/dev/null || true
echo "OK: paso 08 completado. Arranque -> Programs -> Accesorios."

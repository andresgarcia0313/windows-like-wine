#!/usr/bin/env bash
# 08 - Crea los accesos del menú Inicio del escritorio virtual (carpeta Accesorios).
#
# El menú Inicio del explorer de Wine lista archivos .lnk del Start Menu.
# El VBScript de Wine no implementa CreateShortcut (no-op silencioso), así
# que los .lnk se generan con pylnk3 en un entorno Python temporal.
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"

VENV="$(mktemp -d)/venv"
python3 -m venv "$VENV"
"$VENV/bin/pip" -q install pylnk3

"$VENV/bin/python3" << 'EOF'
import pylnk3, os
base = os.path.join(
    os.environ.get("WINEPREFIX", os.path.expanduser("~/.wine")),
    "drive_c", "users", os.environ["USER"],
    "AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Accesorios")
os.makedirs(base, exist_ok=True)
apps = {
    "Calculadora": r"C:\windows\system32\calc.exe",
    "Paint": r"C:\windows\system32\mspaint.exe",
    "Bloc de notas": r"C:\windows\system32\notepad.exe",
    "WordPad": r"C:\windows\system32\write.exe",
    "Administrador de tareas": r"C:\windows\system32\taskmgr.exe",
}
for name, target in apps.items():
    pylnk3.for_file(target, os.path.join(base, name + ".lnk"))
    print("  creado:", name)
EOF

rm -rf "$(dirname "$VENV")"
echo "OK: paso 08 completado. Abre el escritorio y pulsa Arranque -> Programs -> Accesorios."

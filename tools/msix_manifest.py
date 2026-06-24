#!/usr/bin/env python3
"""Lee AppxManifest.xml y emite JSON con lo necesario para instalar/lanzar.

Clasifica la app:
  win32   -> declara un .exe Win32 (lanzable HOY en el windows-like, Nivel 0).
  winui3  -> depende de WinAppSDK/Microsoft.UI.Xaml (fuera de alcance Nivel 0).
  unknown -> sin entrypoint Win32 claro.

Uso: msix_manifest.py <dir-extraido>
Salida (stdout): JSON {id, version, display, executable, entrypoint, dependencies, class}.
"""
import sys
import json
import pathlib
import xml.etree.ElementTree as ET

NS = {
    "d": "http://schemas.microsoft.com/appx/manifest/foundation/windows10",
    "uap": "http://schemas.microsoft.com/appx/manifest/uap/windows10",
}


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: msix_manifest.py <dir>", file=sys.stderr)
        return 2
    root_dir = pathlib.Path(sys.argv[1])
    manifest = root_dir / "AppxManifest.xml"
    if not manifest.is_file():
        print(f"sin AppxManifest.xml en {root_dir}", file=sys.stderr)
        return 1

    root = ET.parse(manifest).getroot()
    ident = root.find("d:Identity", NS)
    app = root.find("d:Applications/d:Application", NS)
    deps = [d.get("Name") for d in root.findall("d:Dependencies/d:PackageDependency", NS)]

    executable = app.get("Executable") if app is not None else None
    entrypoint = app.get("EntryPoint") if app is not None else None
    vis = app.find("uap:VisualElements", NS) if app is not None else None

    name = ident.get("Name") if ident is not None else "app"
    display = (vis.get("DisplayName") if vis is not None else None) or name

    is_win32 = bool(executable) and (
        entrypoint in (None, "Windows.FullTrustApplication")
        or executable.lower().endswith(".exe")
    )
    winui3 = any("WinAppSDK" in (x or "") or "Microsoft.UI.Xaml" in (x or "") for x in deps)
    cls = "win32" if is_win32 else ("winui3" if winui3 else "unknown")

    print(json.dumps({
        "id": name,
        "version": ident.get("Version") if ident is not None else "0.0.0.0",
        "display": display,
        "executable": executable,
        "entrypoint": entrypoint,
        "dependencies": deps,
        "class": cls,
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())

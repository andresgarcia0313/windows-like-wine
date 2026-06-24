#!/usr/bin/env python3
"""Extrae un paquete MSIX/AppX (contenedor OPC/ZIP) en streaming.

Bajo consumo: lee el ZIP entrada por entrada, no carga el paquete entero en RAM.
Seguridad: protege contra path traversal (Zip Slip) verificando que cada destino
quede contenido en el directorio de salida.

Uso: msix_extract.py <paquete.msix> <dir-destino>
Salida (stdout): numero de entradas extraidas. Codigo != 0 si falla.
"""
import sys
import zipfile
import pathlib


def main() -> int:
    if len(sys.argv) != 3:
        print("uso: msix_extract.py <paquete> <destino>", file=sys.stderr)
        return 2
    pkg, dest = sys.argv[1], pathlib.Path(sys.argv[2])
    if not zipfile.is_zipfile(pkg):
        print(f"no es un contenedor ZIP/OPC valido: {pkg}", file=sys.stderr)
        return 1
    dest.mkdir(parents=True, exist_ok=True)
    base = dest.resolve()
    extracted = 0
    with zipfile.ZipFile(pkg) as z:
        for info in z.infolist():
            if info.is_dir():
                continue
            target = (dest / info.filename).resolve()
            if base not in target.parents and target != base:
                print(f"entrada sospechosa, omitida: {info.filename}", file=sys.stderr)
                continue
            z.extract(info, dest)
            extracted += 1
    print(extracted)
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Registro idempotente de apps MSIX instaladas: fuente de verdad para limpiar.

Uso:
  msix_index.py <index.json> add <id> <display> <exe> <lnk> '<deps-csv>'
  msix_index.py <index.json> list
  msix_index.py <index.json> get <id>      # JSON del registro, codigo 1 si no existe
  msix_index.py <index.json> remove <id>
"""
import sys
import json
import pathlib
import datetime


def load(path: pathlib.Path) -> dict:
    return json.loads(path.read_text()) if path.exists() else {}


def save(path: pathlib.Path, data: dict) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2))


def main() -> int:
    if len(sys.argv) < 3:
        print("uso: msix_index.py <index> <add|list|get|remove> ...", file=sys.stderr)
        return 2
    path = pathlib.Path(sys.argv[1])
    cmd = sys.argv[2]
    data = load(path)

    if cmd == "add":
        _, _, _, aid, display, exe, lnk, deps = sys.argv[:8]
        data[aid] = {
            "display": display,
            "exe": exe,
            "lnk": lnk,
            "deps": [d for d in deps.split(",") if d],
            "installedAt": datetime.datetime.now().isoformat(timespec="seconds"),
        }
        save(path, data)
    elif cmd == "list":
        for aid, value in data.items():
            print(f"{aid}\t{value['display']}\t{value['exe']}")
    elif cmd == "get":
        aid = sys.argv[3]
        if aid not in data:
            return 1
        print(json.dumps(data[aid], ensure_ascii=False))
    elif cmd == "remove":
        data.pop(sys.argv[3], None)
        save(path, data)
    else:
        print(f"subcomando desconocido: {cmd}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())

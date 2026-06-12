#!/usr/bin/env bash
# 04 - Instala .NET Framework 4.8 (el paso más largo, ~20 min).
# Funciona en prefix win64 con Wine 11+ (WoW64 completo).
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
export WINEDEBUG=-all

echo "==> Instalando dotnet48 (paciencia: descarga ~70 MB + instalación larga)..."
winetricks -q dotnet48

# GOTCHA documentado: el verbo dotnet48 cambia el prefix a Windows 7
# (lo exige su instalador) y LO DEJA ASÍ. Se restaura Windows 10:
echo "==> Restaurando Windows 10 (dotnet48 lo cambia a win7)..."
winetricks win10

echo "==> Verificación por registro:"
wine reg query "HKLM\\Software\\Microsoft\\NET Framework Setup\\NDP\\v4\\Full" /v Version 2>/dev/null \
  | grep Version || { echo "ERROR: .NET 4.8 no aparece en el registro"; exit 1; }

echo "==> Verificación funcional (compilar y ejecutar C#):"
printf 'class T{static void Main(){System.Console.WriteLine(".NET OK: "+System.Environment.Version);}}' > /tmp/t.cs
wine 'C:\windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe' /nologo \
  /out:'C:\users\Public\t.exe' 'Z:\tmp\t.cs' 2>/dev/null
wine 'C:\users\Public\t.exe' 2>/dev/null | tr -d '\r'
rm -f /tmp/t.cs "$WINEPREFIX/drive_c/users/Public/t.exe"
echo "OK: paso 04 completado."

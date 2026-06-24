#!/usr/bin/env bash
# Genera un MSIX de muestra (app Win32/net48 minima) para validar wl-msix sin
# depender de descargas externas. El binario NO se versiona: se genera on-demand.
# Salida (stdout): ruta del .msix creado. Uso: make-sample-msix.sh [dir-salida]
set -euo pipefail
OUT="${1:-/tmp/wl-msix-sample}"
STAGE="$OUT/stage"
rm -rf "$OUT"; mkdir -p "$STAGE"
command -v dotnet >/dev/null || { echo "falta el SDK .NET (dotnet)" >&2; exit 1; }
command -v zip >/dev/null    || { echo "falta zip" >&2; exit 1; }

# 1) Proyecto net48 minimo que imprime un marcador y termina (corre en Wine Mono).
PROJ="$OUT/src"; mkdir -p "$PROJ"
cat > "$PROJ/HelloMsix.csproj" <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net48</TargetFramework>
    <AssemblyName>HelloMsix</AssemblyName>
    <Nullable>disable</Nullable>
  </PropertyGroup>
</Project>
EOF
cat > "$PROJ/Program.cs" <<'EOF'
class P { static int Main() { System.Console.WriteLine("WL-MSIX-OK"); return 0; } }
EOF
dotnet build "$PROJ/HelloMsix.csproj" -c Release -f net48 --nologo >/dev/null
cp "$PROJ/bin/Release/net48/HelloMsix.exe" "$STAGE/HelloMsix.exe"

# 2) AppxManifest.xml apuntando al .exe Win32 (full trust).
cat > "$STAGE/AppxManifest.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<Package xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
         xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10">
  <Identity Name="HelloMsix.Sample" Version="1.0.0.0" Publisher="CN=windows-like"/>
  <Properties>
    <DisplayName>Hola MSIX</DisplayName>
    <PublisherDisplayName>windows-like</PublisherDisplayName>
    <Logo>HelloMsix.exe</Logo>
  </Properties>
  <Applications>
    <Application Id="App" Executable="HelloMsix.exe" EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements DisplayName="Hola MSIX" Description="muestra Nivel 0"
        BackgroundColor="#0078D7" Square150x150Logo="HelloMsix.exe" Square44x44Logo="HelloMsix.exe"/>
    </Application>
  </Applications>
</Package>
EOF

# 3) Empaquetar como OPC/ZIP -> .msix
MSIX="$OUT/HelloMsix.msix"
( cd "$STAGE" && zip -q -r -X "$MSIX" . )
echo "$MSIX"

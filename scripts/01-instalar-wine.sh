#!/usr/bin/env bash
# 01 - Instala Wine 11 estable desde el repositorio oficial WineHQ y actualiza winetricks.
set -euo pipefail

echo "==> Verificando si Wine ya está instalado..."
if command -v wine >/dev/null 2>&1; then
  echo "Wine presente: $(wine --version)"
else
  echo "==> Agregando repositorio WineHQ..."
  sudo dpkg --add-architecture i386 || true
  sudo mkdir -pm755 /etc/apt/keyrings
  sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
  CODENAME="$(lsb_release -cs)"
  sudo wget -NP /etc/apt/sources.list.d/ \
    "https://dl.winehq.org/wine-builds/ubuntu/dists/${CODENAME}/winehq-${CODENAME}.sources"
  sudo apt update
  echo "==> Instalando winehq-stable..."
  sudo apt install -y --install-recommends winehq-stable
fi

echo "==> Instalando/actualizando winetricks..."
sudo apt install -y winetricks wmctrl
# El self-update pide confirmación Y/N: se responde automáticamente.
echo "Y" | sudo winetricks --self-update || true

echo "==> Versiones instaladas:"
wine --version
winetricks --version | head -1
echo "OK: paso 01 completado."

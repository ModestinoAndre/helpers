#!/bin/bash

set -e

# Repositório URL
SCRIPT_URL="https://raw.githubusercontent.com/ModestinoAndre/helpers/main/wt.sh"

# Diretório de instalação
INSTALL_DIR="/usr/local/bin"
INSTALL_FILE="$INSTALL_DIR/wt.sh"
BINARY_LINK="$INSTALL_DIR/wt"

# Verifica se INSTALL_DIR está no PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo "Aviso: $INSTALL_DIR não está no seu \$PATH."
fi

echo "Baixando wt.sh..."
# Usa sudo se necessário, ou verifica permissão de escrita
if [ -w "$INSTALL_DIR" ]; then
    curl -sSL "$SCRIPT_URL" -o "$INSTALL_FILE"
    chmod +x "$INSTALL_FILE"
    ln -sf "$INSTALL_FILE" "$BINARY_LINK"
    echo "Instalado com sucesso em $BINARY_LINK"
else
    echo "Solicitando permissão de superusuário para instalar em $INSTALL_DIR..."
    sudo curl -sSL "$SCRIPT_URL" -o "$INSTALL_FILE"
    sudo chmod +x "$INSTALL_FILE"
    sudo ln -sf "$INSTALL_FILE" "$BINARY_LINK"
    echo "Instalado com sucesso em $BINARY_LINK"
fi

echo "Você já pode usar o comando 'wt'."

#!/bin/bash

set -e

# Repositório URL
SCRIPT_URL="https://github.com/ModestinoAndre/helpers/wt.sh"

# Diretório de instalação
INSTALL_DIR="/usr/local/bin"

# Verifica se INSTALL_DIR está no PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo "Aviso: $INSTALL_DIR não está no seu \$PATH."
fi

echo "Baixando wt.sh..."
# Usa sudo se necessário, ou verifica permissão de escrita
if [ -w "$INSTALL_DIR" ]; then
    curl -sSL "$SCRIPT_URL" -o "$INSTALL_DIR/wt2.sh"
    chmod +x "$INSTALL_DIR/wt2.sh"
    ln -sf "$INSTALL_DIR/wt2.sh" "$INSTALL_DIR/wt"
    echo "Instalado com sucesso em $INSTALL_DIR/wt"
else
    echo "Solicitando permissão de superusuário para instalar em $INSTALL_DIR..."
    sudo curl -sSL "$SCRIPT_URL" -o "$INSTALL_DIR/wt2.sh"
    sudo chmod +x "$INSTALL_DIR/wt2.sh"
    sudo ln -sf "$INSTALL_DIR/wt2.sh" "$INSTALL_DIR/wt"
    echo "Instalado com sucesso em $INSTALL_DIR/wt"
fi

echo "Você já pode usar o comando 'wt'."

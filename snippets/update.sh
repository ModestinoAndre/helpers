# shellcheck shell=bash

check_for_updates() {
  # Tenta baixar a versão remota do script para extrair a versão
  # Usamos um timeout curto para não travar o uso do script se não houver internet
  REMOTE_VERSION=$(curl -s --connect-timeout 2 "$SCRIPT_URL" | grep "^VERSION=" | head -1 | cut -d'"' -f2)

  if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$VERSION" ]; then
    echo "Uma nova versão ($REMOTE_VERSION) do 'wt' está disponível. A sua versão atual é $VERSION."
    read -p "Deseja atualizar agora? (s/N): " update_response
    case "$update_response" in
      [sS][iI][mM]|[sS])
        echo "Iniciando atualização via instalador..."
        TEMP_INSTALLER=$(mktemp /tmp/wt-install.XXXXXX.sh)
        if curl -sSL "$INSTALLER_URL" -o "$TEMP_INSTALLER"; then
          chmod +x "$TEMP_INSTALLER"
          bash "$TEMP_INSTALLER"
          rm "$TEMP_INSTALLER"
          echo "Atualização concluída."
          exit 0
        else
          echo "Erro ao baixar o instalador."
          rm -f "$TEMP_INSTALLER"
          exit 1
        fi
        ;;
      *)
        echo "Pulando atualização."
        ;;
    esac
  fi
}

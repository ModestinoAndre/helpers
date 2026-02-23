# shellcheck shell=bash

wt_install_completion() {
  # Se for chamado via source <(wt completion), apenas emite o script
  if [[ ! -t 1 ]]; then
    wt_completion_script
    exit 0
  fi

  # Caso contrário, tenta registrar permanentemente
  echo "Configurando autocompletação Bash..."
  
  local SHELL_CONFIG=""
  if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
  elif [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
  fi

  if [ -z "$SHELL_CONFIG" ]; then
    echo "Erro: Não foi possível encontrar um arquivo de configuração do shell (~/.bashrc, ~/.bash_profile ou ~/.zshrc)."
    echo "Para ativar manualmente, adicione a seguinte linha ao seu arquivo de configuração:"
    echo "source <(wt completion)"
    exit 1
  fi

  local LINE_TO_ADD="source <(wt completion)"
  if grep -Fq "$LINE_TO_ADD" "$SHELL_CONFIG"; then
    echo "A autocompletação já está configurada em $SHELL_CONFIG."
  else
    echo "" >> "$SHELL_CONFIG"
    echo "# Autocompletação para o comando 'wt'" >> "$SHELL_CONFIG"
    echo "$LINE_TO_ADD" >> "$SHELL_CONFIG"
    echo "Configuração adicionada a $SHELL_CONFIG."
    echo "Recarregue o seu shell ou execute: source $SHELL_CONFIG"
  fi
  
  # Também emite para o caso de querer usar imediatamente via eval
  wt_completion_script
  exit 0
}

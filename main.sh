#!/bin/bash

set -e

# Versão atual do script
VERSION="1.0.5"
SCRIPT_URL="https://raw.githubusercontent.com/ModestinoAndre/helpers/refs/heads/main/wt.sh"
INSTALLER_URL="https://raw.githubusercontent.com/ModestinoAndre/helpers/refs/heads/main/install.sh"

# Carrega funções modularizadas dos snippets
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for f in snippets/update.sh snippets/autocomplete.sh snippets/install_completion.sh snippets/usage.sh snippets/add.sh snippets/ls.sh snippets/rm.sh; do
  # shellcheck disable=SC1090
  [ -f "$SCRIPT_DIR/$f" ] && . "$SCRIPT_DIR/$f"
done

# Verifica se os parâmetros básicos foram fornecidos
if [ $# -lt 1 ]; then
  usage
fi

COMMAND=$1

# Comandos que não exigem branch ou repositório git podem ser tratados aqui
if [ "$COMMAND" == "update" ]; then
  check_for_updates
  echo "Você já está na versão mais recente ($VERSION)."
  exit 0
fi

if [ "$COMMAND" == "completion" ]; then
  wt_install_completion
fi

# Verifica atualizações silenciosamente ou em comandos normais
# Para evitar lentidão em cada comando, poderíamos salvar a data da última verificação,
# mas para este exemplo, faremos sempre que houver 2 ou mais argumentos (uso normal).
if [ $# -ge 2 ]; then
  check_for_updates
fi

if [[ "$COMMAND" == "add" || "$COMMAND" == "rm" ]]; then
  if [ $# -lt 2 ]; then
    usage
  fi
fi

BRANCH_NAME=$2
EXTRA_ARG=$3

# 1. Identificar a raiz do repositório git atual
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$GIT_ROOT" ]; then
  echo "Erro: Não foi possível identificar a raiz do repositório git."
  exit 1
fi

case "$COMMAND" in
  add)
    OPEN_IDE=false
    if [ "$EXTRA_ARG" == "--ide" ]; then
      OPEN_IDE=true
    fi
    wt_add "$BRANCH_NAME" "$OPEN_IDE"
    ;;

  rm)
    wt_rm "$BRANCH_NAME"
    ;;

  ls)
    wt_ls
    ;;

  completion)
    # Este caso agora é tratado no início do script para evitar dependências de git root
    ;;

  *)
    echo "Erro: Comando desconhecido '$COMMAND'."
    usage
    ;;
esac
# test comment

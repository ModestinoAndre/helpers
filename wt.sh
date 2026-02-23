#!/bin/bash

set -e

# Função de ajuda
usage() {
  echo "Uso: $0 <comando> <branch-name> [opções]"
  echo "Comandos:"
  echo "  add  Adiciona um novo worktree para a branch fornecida"
  echo "  rm   Remove o worktree da branch fornecida"
  echo ""
  echo "Opções para 'add':"
  echo "  --ide  Abre o IntelliJ IDEA no diretório do worktree criado"
  exit 1
}

# Verifica se os parâmetros básicos foram fornecidos
if [ $# -lt 2 ]; then
  usage
fi

COMMAND=$1
BRANCH_NAME=$2
EXTRA_ARG=$3

# 1. Identificar a raiz do repositório git atual
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$GIT_ROOT" ]; then
  echo "Erro: Não foi possível identificar a raiz do repositório git."
  exit 1
fi

# Função para adicionar worktree
add_wt() {
  local branch_name=$1
  local open_ide=$2

  # Mudar para o diretório ../worktrees a partir da raiz do git
  cd "$GIT_ROOT" || exit 1
  WORKTREES_DIR="../worktrees"

  if [ ! -d "$WORKTREES_DIR" ]; then
    echo "WARN: O diretório $WORKTREES_DIR não existe. Criando agora..."
    mkdir -p "$WORKTREES_DIR"
  fi

  TARGET_PATH=$(cd "$WORKTREES_DIR" && pwd)/"$branch_name"

  # Verifica se o worktree já existe
  if [ -d "$TARGET_PATH" ]; then
    echo "Erro: O worktree já existe em '$TARGET_PATH'."
    exit 1
  fi

  # Verifica se a branch já existe
  if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
    echo "Branch '$branch_name' já existe. Utilizando branch existente..."
    git worktree add "$TARGET_PATH" "$branch_name"
  else
    echo "Criando nova branch '$branch_name' e adicionando worktree em '$TARGET_PATH'..."
    git worktree add -b "$branch_name" "$TARGET_PATH"
  fi

  cd "$TARGET_PATH"

  if [ "$open_ide" = true ]; then
    echo "Abrindo o IntelliJ IDEA no diretório $TARGET_PATH..."
    idea . || true
  fi

  echo ""
  echo "Execute o comando a seguir para mudar para o worktree criado:"
  echo "cd $TARGET_PATH"
}

# Função para remover worktree
rm_wt() {
  local branch_name=$1

  GIT_MAIN_DIR=$(dirname $(git rev-parse --git-common-dir))
  echo "GIT_MAIN_DIR: $GIT_MAIN_DIR"

  # Verifica se existe um worktree para a branch
  WORKTREE_PATH=$(git worktree list --porcelain | grep -B 2 "branch refs/heads/$branch_name" | grep "^worktree " | awk '{print $2}')

  if [ -z "$WORKTREE_PATH" ]; then
    echo "Erro: Não foi encontrado um worktree para a branch '$branch_name'."
    exit 1
  fi

  echo "Worktree encontrado em: $WORKTREE_PATH"

  # Verifica se existe código não commitado no worktree
  # Usamos uma subshell para não perder o contexto se o cd falhar
  if (cd "$WORKTREE_PATH" && [ -n "$(git status --porcelain)" ]); then
    echo "Aviso: Existem alterações não commitadas no worktree '$branch_name'."
    read -p "Deseja descartar as alterações e remover o worktree? (s/N): " response
    case "$response" in
      [sS][iI][mM]|[sS])
        echo "Descartando alterações e removendo worktree..."
        git worktree remove --force "$WORKTREE_PATH"
        ;;
      *)
        echo "Operação cancelada pelo usuário."
        exit 0
        ;;
    esac
  else
    # Remover o worktree se não houver alterações
    echo "Removendo worktree '$branch_name'..."
    git worktree remove "$WORKTREE_PATH"
  fi

  echo "Worktree para a branch '$branch_name' removido com sucesso."
  echo "Execute o comando a seguir para voltar para o repositório principal:"
  echo "cd $GIT_MAIN_DIR"
}

case "$COMMAND" in
  add)
    OPEN_IDE=false
    if [ "$EXTRA_ARG" == "--ide" ]; then
      OPEN_IDE=true
    fi
    add_wt "$BRANCH_NAME" "$OPEN_IDE"
    ;;

  rm)
    rm_wt "$BRANCH_NAME"
    ;;

  *)
    echo "Erro: Comando desconhecido '$COMMAND'."
    usage
    ;;
esac

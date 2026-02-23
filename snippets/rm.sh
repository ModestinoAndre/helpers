# shellcheck shell=bash

wt_rm() {
  local branch_name=$1

  GIT_MAIN_DIR=$(dirname "$(git rev-parse --git-common-dir)")
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

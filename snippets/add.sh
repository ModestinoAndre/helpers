# shellcheck shell=bash

wt_add() {
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

#!/bin/bash

# ESTE ARQUIVO É GERADO AUTOMATICAMENTE. NÃO EDITE DIRETAMENTE.
# Edite main.sh ou os arquivos em snippets/ e execute ./compile.sh


set -e

# Versão atual do script
VERSION="1.0.5"
SCRIPT_URL="https://raw.githubusercontent.com/ModestinoAndre/helpers/refs/heads/main/wt.sh"
INSTALLER_URL="https://raw.githubusercontent.com/ModestinoAndre/helpers/refs/heads/main/install.sh"

# Carrega funções modularizadas dos snippets
# Snippets incluídos
# --- Início de update.sh ---

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
# --- Fim de update.sh ---

# --- Início de autocomplete.sh ---

wt_completion_script() {
  cat <<'__WT_BASH_COMPLETION__'
# bash completion para o comando 'wt'
# Para ativar no shell atual: source <(wt completion)
# Ou adicione a linha acima ao seu ~/.bashrc ou ~/.bash_profile

_wt_complete() {
  local cur prev words cword
  COMPREPLY=()

  # Captura palavras de forma compatível, mesmo sem bash-completion instalado
  if declare -F _get_comp_words_by_ref >/dev/null 2>&1; then
    _get_comp_words_by_ref -n : cur prev words cword
  else
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    words=(${COMP_WORDS[*]})
    cword=${COMP_CWORD}
  fi

  # Primeira posição após o comando: sugerir subcomandos
  if [[ $cword -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "add ls rm update completion" -- "$cur") )
    return 0
  fi

  local subcmd=${words[1]}

  # Autocomplete específico para 'rm': sugerir branches que possuem worktree
  if [[ $subcmd == rm && $cword -eq 2 ]]; then
    # Extrai nomes de branches de 'git worktree list --porcelain'
    local branches
    branches=$(git worktree list --porcelain 2>/dev/null | awk '/^branch /{gsub("refs/heads/","",$2); print $2}' | sort -u)
    if [[ -n $branches ]]; then
      COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
    fi
    return 0
  fi
}

# Registra o completion para 'wt'
# Se estiver no zsh, tente habilitar bashcompinit para compatibilidade
if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz bashcompinit 2>/dev/null || true
  bashcompinit 2>/dev/null || true
fi
complete -F _wt_complete wt 2>/dev/null || true
__WT_BASH_COMPLETION__
}
# --- Fim de autocomplete.sh ---

# --- Início de install_completion.sh ---

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
# --- Fim de install_completion.sh ---

# --- Início de usage.sh ---

usage() {
  echo "Uso: $0 <comando> [branch-name] [opções]"
  echo "Comandos:"
  echo "  add         Adiciona um novo worktree para a branch fornecida"
  echo "  ls          Lista os worktrees do repositório git"
  echo "  rm          Remove o worktree da branch fornecida"
  echo "  update      Atualiza o script para a versão mais recente"
  echo "  completion  Configura a autocompletação Bash permanentemente"
  echo ""
  echo "Opções para 'add':"
  echo "  --ide  Abre o IntelliJ IDEA no diretório do worktree criado"
  exit 1
}
# --- Fim de usage.sh ---

# --- Início de add.sh ---

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
# --- Fim de add.sh ---

# --- Início de ls.sh ---

wt_ls() {
  git worktree list
}
# --- Fim de ls.sh ---

# --- Início de rm.sh ---

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
# --- Fim de rm.sh ---


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

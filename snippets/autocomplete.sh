# shellcheck shell=bash

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

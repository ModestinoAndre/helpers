# shellcheck shell=bash

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

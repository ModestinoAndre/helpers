# helpers
Scripts utilitários para produtividade no terminal.

## wt (Worktree Helper)
O `wt` é um script para facilitar o gerenciamento de [Git Worktrees](https://git-scm.com/docs/git-worktree). Ele organiza seus worktrees em um diretório padrão (`../worktrees/`) fora do diretório principal do repositório, mantendo seu ambiente de trabalho limpo.

### Instalação

Para instalar ou atualizar o `wt`, execute:

```bash
curl -sSL https://raw.githubusercontent.com/ModestinoAndre/helpers/refs/heads/main/install.sh | bash
```

### Autocompletação

O `wt` suporta autocompletação para comandos e branches. Para configurar permanentemente no seu shell (`bash` ou `zsh`), execute:

```bash
wt completion
```

Ou, para usar apenas na sessão atual:
```bash
source <(wt completion)
```

### Uso

O formato básico do comando é:
```bash
wt <comando> [argumentos]
```

#### Comandos disponíveis:

- **`add <branch-name> [--ide]`**
  Cria um novo worktree para a branch especificada.
  - O worktree será criado em `../worktrees/<branch-name>`.
  - Se a branch não existir localmente, o script tentará criá-la a partir de `origin`.
  - Se a branch já tiver um worktree, ele apenas informará o caminho.
  - `--ide`: Abre o IntelliJ IDEA (`idea`) no diretório do novo worktree após a criação.

- **`ls`**
  Lista todos os worktrees associados ao repositório git atual.

- **`rm <branch-name>`**
  Remove o worktree associado à branch especificada e limpa referências administrativas do Git.

- **`update`**
  Verifica se há uma nova versão do script `wt` disponível e realiza a atualização automática.

- **`completion`**
  Configura a autocompletação no arquivo de configuração do seu shell (`.bashrc`, `.zshrc`, etc.).

### Exemplos

```bash
# Adicionar um worktree para uma nova branch de funcionalidade
wt add feature/minha-feature

# Adicionar e abrir no IntelliJ
wt add bugfix/correcao-urgente --ide

# Listar worktrees ativos
wt ls

# Remover um worktree quando terminar a tarefa
wt rm feature/minha-feature
```

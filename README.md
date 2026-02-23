# helpers
Scripts utilitários

## wt
Script para gerenciar git worktrees.

### Instalação

```bash
curl -sSL https://raw.githubusercontent.com/ModestinoAndre/helpers/main/install.sh | bash
```

### Uso:
```bash
wt add <branch-name> [--ide]
wt rm <branch-name>
```

- `add`: Cria (ou usa existente) uma branch e adiciona um worktree em `../worktrees/<branch-name>`.
- `rm`: Remove o worktree associado à branch.
- `--ide`: Abre o IntelliJ IDEA no diretório do worktree (apenas para `add`).

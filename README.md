# helpers
Scripts utilitários

## wt2.sh
Script para gerenciar git worktrees.

### Uso:
```bash
./wt2.sh add <branch-name> [--ide]
./wt2.sh rm <branch-name>
```

- `add`: Cria (ou usa existente) uma branch e adiciona um worktree em `../worktrees/<branch-name>`.
- `rm`: Remove o worktree associado à branch.
- `--ide`: Abre o IntelliJ IDEA no diretório do worktree (apenas para `add`).

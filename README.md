# dotfiles
My dotfiles

## Branches
Config is split per OS. Keep OS-specific changes on their own branch.

| branch | target |
| --- | --- |
| `darwin` | macOS |
| `linux` | Linux (Homebrew on Linux) |

i use ```stow```

# Usage
in root dir

### create link
```zsh
stow -v dirname
```

### unlink
```zsh
stow -vD dirname
```

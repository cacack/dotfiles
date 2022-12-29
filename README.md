# dotfiles

> This is my terminal. There are many like it, but this one is mine.
> My terminal is my best friend. It is my life. I must master it as I must master my life.
> Without me, my terminal is useless. Without my terminal, I am useless.

My various configuration files to make ${HOME} home.

## Installation

### For a private system

1. Generate new SSH keys.
1. Add keys to GitLab/GitHub account.
1. Clone repo SSH URL.
1. Run setup.

```sh
make bootstrap
```

### For a shared system

1. Retrieve and run bash script.

```sh
curl -sSL https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh | bash --
```

## Tools I currently use

- [kitty](https://github.com/kovidgoyal/kitty)
- [tmux](https://github.com/tmux/tmux)
- [zsh](https://www.zsh.org/)
- [starship](https://github.com/starship/starship)
- [lsd](https://github.com/Peltoche/lsd)
- [fzf](https://github.com/junegunn/fzf)
- [neovim](https://neovim.io)

## License

Copyright (c) 2022, Chris Clonch. Distributed under an [MIT License][].

[mit license]: http://www.opensource.org/licenses/MIT

# Dotfiles

This is a simple repository of my Vim, Neovim, and Tmux configurations. If you like my configs and want to use them, run:
```bash
git clone git@github.com:KushalMeghani1644/dotfiles.git
```

If you use HTTP

```bash
git clone https://github.com/KushalMeghani1644/dotfiles
```

Then move the files to the respective places:

- Vim config: `~/.vimrc`
- Neovim config: `~/.config/nvim/init.lua`
- Tmux config: `~/.tmux.conf`
- Ghostty conffig: `~/.config/ghostty/config`

If you prefer, create symbolic links:
```bash
ln -sf ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
```

Or run the script provided in the repo:
```bash
cd ~/dotfiles
chmod +x clone.sh
./clone.sh
```


## LICENSE

This repository is licensed under the Apache 2.0 LICENSE, see [LICENSE](LICENSE) for more details.

## Thank you!

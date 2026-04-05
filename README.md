Run the following command to install these dotfiles to a new system:

```
curl https://raw.githubusercontent.com/Andrewvlad/dotfiles/master/scripts/config-init | bash
```

How to add dotfiles to the config:

```
config add ~/.config/something/somefile
config commit -m "add somefile"
config push
```

If you don't have the matching services installed:

```
sudo apt install zsh neofetch
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
```

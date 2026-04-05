# Track the .dotfiles bare repo
alias config="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# Auto suggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' forward-word

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS # No back-to-back dups
setopt autocd nomatch
unsetopt beep
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }
# End of lines configured by zsh-newuser-install

# Tab completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)--color=auto}"                        # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                                                # automatically find new executables in path
zstyle ':completion:*' menu select                                                # Highlight menu selection

# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit && compinit

# Bind up/down keys to search history from what already is in the prompt
autoload -Uz history-search-en
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "$terminfo[kcuu1]" history-beginning-search-backward
bindkey "$terminfo[kcud1]" history-beginning-search-forward

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


. "$HOME/.local/bin/env"
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Ignore IO prompt when launching Neofetch (off|quiet)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Launch neofetch (sys info)
neofetch

export PATH="$PATH:/opt/nvim/bin"

# Alias NVIM if installed
if command -v "nvim" &> /dev/null; then
    alias vi="nvim"
    alias vim="nvim"
fi



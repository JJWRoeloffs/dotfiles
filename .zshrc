# Show the calander at the start of the terminal
when

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Add stuff to the path for different programming languages.
# the HOME bin should be _first_ such that it can be used to overwrite stuff
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:/var/lib/flatpak/bin:$PATH
# Rust
export PATH=$PATH:$HOME/.cargo/bin
# Scala
export PATH=$PATH:$HOME/.local/share/coursier/bin
# Go
export PATH=$PATH:/usr/local/go/bin
# Haskell
export GHCUP_USE_XDG_DIRS=1
source ~/.local/share/ghcup/env

# Basic settings
HYPHEN_INSENSITIVE="true"
setopt appendhistory sharehistory histignorespace hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUP=erase
bindkey '^p' history-search-backward
bindkey '^f' history-search-forward
zstyle ':completion:*' rehash true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Setting up zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Add powerlevel10K for the pure prompt
zinit ice depth=1; zinit light romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Basic plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Load the completions
autoload -U compinit && compinit
bindkey '^y' autosuggest-accept

# oh-my-zsh plugins
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::debian
zinit snippet OMZP::pip
zinit snippet OMZP::docker-compose
zinit snippet OMZP::python
zinit snippet OMZP::rust
zinit snippet OMZP::sbt
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Recommended in the docs
zinit cdreplay -q

# aliases
alias ls='ls --color'
alias ll='ls -lah --color'
alias grep='grep --color=auto'

# change curor
echo -e -n "\x1b[\x34 q"

# Set editor
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='nvim'
fi

# add LF command to change dir when moving around
clf () {
	tmp="$(mktemp)"
	lf -last-dir-path="$tmp" "$@"
	if [ -f "$tmp" ]; then
		dir="$(cat "$tmp")"
		rm -f "$tmp"
		if [ -d "$dir" ]; then
			if [ "$dir" != "$(pwd)" ]; then
				cd "$dir"
			fi
		fi
	fi
}

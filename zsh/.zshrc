# Enable zsh completion system
autoload -U +X bashcompinit && bashcompinit
autoload -U +X compinit && compinit

# Homebrew configuration (macOS only)
if [[ "$OSTYPE" == darwin* ]]; then
    # Detect homebrew installation path
    if [ -f "/opt/homebrew/bin/brew" ]; then
        BREW_BIN="/opt/homebrew/bin/brew"
    elif [ -f "/usr/local/bin/brew" ]; then
        BREW_BIN="/usr/local/bin/brew"
    fi

    if [[ -n "$BREW_BIN" && -x "$BREW_BIN" ]]; then
        export BREW_PREFIX="$("$BREW_BIN" --prefix)"
        # Add homebrew paths to PATH and MANPATH
        export PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"
        export MANPATH="$BREW_PREFIX/share/man:$MANPATH"
        
        # Add opt packages to PATH
        for bindir in "$BREW_PREFIX"/opt/*/bin; do
            [[ -d "$bindir" ]] && export PATH="$bindir:$PATH"
        done
        for bindir in "$BREW_PREFIX"/opt/*/libexec/gnubin; do
            [[ -d "$bindir" ]] && export PATH="$bindir:$PATH"
        done
        for mandir in "$BREW_PREFIX"/opt/*/share/man; do
            [[ -d "$mandir" ]] && export MANPATH="$mandir:$MANPATH"
        done
    fi
fi

# Environment variables
export PATH="$HOME/.docker/bin:$PATH"

# Load antidote plugin manager
if [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
    source "$HOME/.antidote/antidote.zsh"
    source <(antidote init)
    
    # Set ZSH to antidote's oh-my-zsh installation
    ANTIDOTE_HOME="$(antidote home)"
    export ZSH="$ANTIDOTE_HOME/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh"
    
    # Load plugins from .zsh_plugins.txt
    antidote bundle < ~/.zsh_plugins.txt
    
    # Conditionally load brew plugin only on macOS
    if [[ "$OSTYPE" == darwin* ]]; then
        antidote bundle robbyrussell/oh-my-zsh path:plugins/brew
    fi
else
    echo "Warning: antidote not found. Please run the setup script first."
fi

# aliases
alias c="clear"
alias clb="clean_local_branches"
alias es="exec zsh"
alias gitauth="gh auth login setup-git"
alias myip="dig +short -4 myip.opendns.com @resolver1.opendns.com"
alias pip="pip3"
alias pull="git pull"
alias push="git push"
alias python="python3"
alias ssologin="unsetprofile && aws sso login --profile default"
alias tti="tofu init"
alias ttplf="tofu plan -lock=false"
alias ttlockgen="tofu providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64 -platform=linux_arm64 -platform=darwin_arm64"

# functions
function listprofiles(){
  echo "Available AWS Profiles:\n"
  aws configure list-profiles
}

function setprofile() {
  export AWS_PROFILE=$1
  echo "AWS_PROFILE set to $AWS_PROFILE"
}

function unsetprofile() {
  unset AWS_PROFILE
  echo "AWS_PROFILE unset"
}

function get_account_id() {
  unset AWS_PROFILE
  aws sts get-caller-identity --query Account --output text --no-cli-pager --profile $1 
}

function check_logged_in() {
  if aws sts get-caller-identity --profile default > /dev/null 2>&1; then
    echo "Already Logged into AWS SSO"
  else
    echo "Authenticating AWS SSO"
    ssologin
  fi
}

function clean_local_branches() {
  git remote prune origin
  git branch -a | egrep -v "(^\*|master|main|origin)" | xargs -n 1 git branch -d
}

# AWS SSO session check (only if AWS CLI is available)
if command -v aws &> /dev/null; then
  check_logged_in
fi

# GitHub token (only if gh is available)
if command -v gh &> /dev/null; then
  export GH_TOKEN=$(gh auth token 2>/dev/null || echo "")
fi

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# Powerlevel10k Instant Prompt - MUST be first (before any output/commands)
# ============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH and Homebrew are configured in ~/.zshenv (applies to all zsh contexts)

# ============================================================================
# Zsh Completion System - Initial compinit so compdef is available for plugins
# ============================================================================
autoload -Uz compinit
local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n "$zcompdump"(#qN.mh-24) ]]; then
    compinit -C -d "$zcompdump"
else
    compinit -u -d "$zcompdump"
fi

# ============================================================================
# Antidote Plugin Manager - Optimized initialization
# ============================================================================
if [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
    source "$HOME/.antidote/antidote.zsh"

    # Set ZSH to antidote's oh-my-zsh installation
    export ANTIDOTE_HOME="${ANTIDOTE_HOME:-$(antidote home)}"
    export ZSH="$ANTIDOTE_HOME/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh"

    # ZSH_CACHE_DIR is normally set by oh-my-zsh.sh, but we load path:lib
    # directly so it's never defined. Plugins like docker and uv need it.
    export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$ZSH/cache}"
    [[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"

    # antidote load reads ~/.zsh_plugins.txt and generates a static
    # cache at ~/.zsh_plugins.zsh, regenerating when the txt changes
    antidote load

    # Re-run compinit to pick up fpath entries added by zsh-completions
    compinit -u -d "$zcompdump"
fi

# ============================================================================
# Powerlevel10k Configuration
# ============================================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# Aliases (preserved exactly as they were)
# ============================================================================
alias c="clear"
alias clb="clean_local_branches"
alias es="exec zsh"
alias gitauth="gh auth login && gh auth setup-git"
alias ll="ls -lh"
alias myip="dig +short -4 myip.opendns.com @resolver1.opendns.com"
alias pip="pip3"
alias pull="git pull"
alias push="git push"
alias python="python3"
alias ssologin="unsetprofile && aws sso login"
alias tti="tofu init"
alias ttplf="tofu plan -lock=false"
alias ttlockgen="tofu providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64 -platform=linux_arm64 -platform=darwin_arm64"

# ============================================================================
# Functions (preserved exactly as they were)
# ============================================================================
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
  git branch -a | grep -Ev "(^\*|master|main|origin)" | xargs -n 1 git branch -D
}

function claude() {
  if command -v bedrock-token &> /dev/null; then
    eval "$(bedrock-token)"
  fi
  command claude "$@"
}

# ============================================================================
# AWS SSO Check - Deferred to background for faster startup
# ============================================================================
# Run AWS check in background to avoid blocking shell startup
# Only runs once per session and only in interactive shells
#
# Commented out for remote EC2 developent which uses an instance
# profile for authenticating and accessing AWS
#
#if [[ -o interactive ]] && command -v aws &> /dev/null && [[ -z "$AWS_CHECK_DONE" ]]; then
#  export AWS_CHECK_DONE=1
#  # Run in background to avoid blocking startup
#  (aws sts get-caller-identity --profile default > /dev/null 2>&1 || {
#    # Only show message if not logged in (avoid noise if command fails for other reasons)
#    if ! aws sts get-caller-identity --profile default > /dev/null 2>&1; then
#      echo "AWS SSO: Not logged in (run 'ssologin' to authenticate)" >&2
#    fi
#  }) &!
#fi

# ============================================================================
# GitHub Token - Cached to avoid repeated calls
# ============================================================================
# Only set if gh is available, not already set, and auth token is non-empty
if [[ -o interactive ]] && command -v gh &> /dev/null && [[ -z "$GH_TOKEN" ]]; then
  _gh_token=$(gh auth token 2>/dev/null)
  [[ -n "$_gh_token" ]] && export GH_TOKEN="$_gh_token"
  unset _gh_token
fi

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select

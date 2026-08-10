# ============================================================================
# Powerlevel10k Instant Prompt - MUST be first (before any output/commands)
# ============================================================================
# The first shell after a rebuild prints one-time "antidote cloning..." output
# while plugins are fetched. `quiet` tells instant prompt that output is
# expected and suppresses the otherwise-alarming warning. Steady-state launches
# produce no output, so this is invisible after the first run.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH additions
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# ============================================================================
# Headless auth-URL clipboard bridge
# ============================================================================
# Snapshot this pane's tty on every shell start so the xdg-open shim (see
# ~/.local/bin/xdg-open) can still OSC 52-copy to it even from subprocesses
# that detach from the controlling terminal (e.g. Python's webbrowser
# BackgroundBrowser). Only wires up $BROWSER when the shim is actually present
# so this stays inert on machines that don't have it (e.g. the Mac).
export PANE_TTY="$(tty 2>/dev/null)"
[[ -x "$HOME/.local/bin/xdg-open" ]] && export BROWSER="$HOME/.local/bin/xdg-open"

# Pin the Snowflake connector's EXTERNALBROWSER/oauth-code local callback to a
# fixed port (default is OS-ephemeral, i.e. a different port every login) so a
# single permanent local SSH port-forward covers every future login instead of
# chasing a new port each time. See snowflake.connector.auth.webbrowser.
export SF_AUTH_SOCKET_PORT=38888

# ============================================================================
# Claude Code
# ============================================================================
# Set here rather than in ~/.claude/settings.json so that file stays byte-
# identical across the Mac and the devenv. The `env` block in settings.json
# does literal assignment with no shell expansion, so it cannot use $HOME and
# would need a different absolute path per machine. The workspace lives at
# ~/ai-dev/claude-workspace on both (on the devenv that's a symlink into
# /mnt/devdata), so $HOME resolves correctly without an OS conditional.
export CLAUDE_WORKSPACE_DIR="$HOME/ai-dev/claude-workspace"

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

    export ANTIDOTE_HOME="${ANTIDOTE_HOME:-$(antidote home)}"

    # ZSH_CACHE_DIR is normally set by oh-my-zsh.sh, but we load path:lib
    # directly so it's never defined. Plugins like docker and uv write
    # completion dumps here. Keep it OUTSIDE the antidote clone tree: a
    # directory sitting at the ohmyzsh clone path makes antidote think the
    # bundle is already cloned and skip it, leaving broken `source` lines.
    export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    [[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"

    # antidote load reads ~/.zsh_plugins.txt and generates a static
    # cache at ~/.zsh_plugins.zsh, regenerating when the txt changes
    antidote load

    # Point ZSH at the real ohmyzsh clone. Ask antidote for the path rather
    # than hardcoding it — the directory naming is an antidote-version detail
    # (2.x uses github.com/owner/repo; 1.x used a URL-encoded name).
    export ZSH="$(antidote path ohmyzsh/ohmyzsh 2>/dev/null)"

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
alias fre="fleet-reattach"
alias gitauth="gh auth login && gh auth setup-git"
alias ll="ls -lh"
alias myip="dig +short -4 myip.opendns.com @resolver1.opendns.com"
alias pip="pip3"
alias pull="git pull"
alias push="git push"
alias python="python3"
alias ssh='ghostty +ssh --'
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

function ssologin() {
  unsetprofile
  # PKCE's browser redirect needs a localhost callback, which doesn't reach
  # anywhere useful on a headless Linux box connected over SSH. Device code
  # avoids that entirely, so use it there; Mac has a real local browser.
  if [[ "$(uname)" == "Linux" ]]; then
    aws sso login --use-device-code "$@"
  else
    aws sso login "$@"
  fi
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
#if [[ -o interactive ]] && command -v gh &> /dev/null && [[ -z "$GH_TOKEN" ]]; then
#  _gh_token=$(gh auth token 2>/dev/null)
#  [[ -n "$_gh_token" ]] && export GH_TOKEN="$_gh_token"
#  unset _gh_token
#fi

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select

# Cortex CLI completion (disable via /settings in cortex)
[[ -s ~/.zsh/completions/cortex.zsh ]] && source ~/.zsh/completions/cortex.zsh

# Restore a terminal wedged by a dead remote session (mouse-mode garbage,
# no echo, etc.) without a full 'reset'
fixterm() {
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1005l\e[?1006l\e[?1015l\e[?2004l\e[?25h'
  stty sane
}

. "$HOME/.local/bin/env"

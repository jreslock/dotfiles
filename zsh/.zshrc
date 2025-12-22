# ============================================================================
# Powerlevel10k Instant Prompt - MUST be first (before any output/commands)
# ============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# PATH Management - Skip duplicates to prevent PATH bloat
# ============================================================================
typeset -U path PATH

# ============================================================================
# Workspace PATH (devcontainer) - optimized to avoid redundant sourcing
# ============================================================================
if [[ -d "/workspace/.devcontainer-data/.local/share/../bin" ]]; then
  case ":${PATH}:" in
    *:"/workspace/.devcontainer-data/.local/share/../bin":*) ;;
    *) path=("/workspace/.devcontainer-data/.local/share/../bin" $path) ;;
  esac
fi

# ============================================================================
# Homebrew configuration (macOS only) - optimized
# ============================================================================
if [[ "$OSTYPE" == darwin* && -z "$BREW_PREFIX" ]]; then
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        export BREW_PREFIX="/opt/homebrew"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        export BREW_PREFIX="/usr/local"
    fi

    if [[ -n "$BREW_PREFIX" ]]; then
        # Add core homebrew paths
        path=("$BREW_PREFIX/bin" "$BREW_PREFIX/sbin" $path)
        export MANPATH="$BREW_PREFIX/share/man:$MANPATH"

        # Add common opt packages (only if they exist)
        [[ -d "$BREW_PREFIX/opt/gnu-sed/libexec/gnubin" ]] && path=("$BREW_PREFIX/opt/gnu-sed/libexec/gnubin" $path)
        [[ -d "$BREW_PREFIX/opt/coreutils/libexec/gnubin" ]] && path=("$BREW_PREFIX/opt/coreutils/libexec/gnubin" $path)
    fi
fi

# ============================================================================
# Essential PATH additions
# ============================================================================
path=("$HOME/.docker/bin" "$HOME/.local/bin" $path)

# ============================================================================
# Zsh Completion System - Optimized with caching
# ============================================================================
if [[ -z "$_comp_setup" ]]; then
    # Only load bashcompinit if actually needed (most modern setups don't need it)
    # compinit can handle most completions natively
    autoload -Uz compinit
    
    # Check if completion cache is fresh (less than 24 hours old)
    # -C: skip security check if cache is fresh (major speedup)
    # -u: update cache if older than 24 hours
    # -d: specify dumpfile location
    local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
        # Cache is fresh, skip security check for speed
        compinit -C -d "$zcompdump"
    else
        # Cache is stale or missing, update it
        compinit -u -d "$zcompdump"
    fi
    
    # Mark as setup to prevent duplicate initialization
    _comp_setup=1
fi

# ============================================================================
# Antidote Plugin Manager - Optimized initialization
# ============================================================================
if [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
    source "$HOME/.antidote/antidote.zsh"

    # Initialize antidote (cache the init output if possible)
    ANTIDOTE_INIT_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/antidote-init.zsh"
    if [[ -f "$ANTIDOTE_INIT_CACHE" ]] && [[ "$ANTIDOTE_INIT_CACHE" -nt "$HOME/.antidote/antidote.zsh" ]]; then
        source "$ANTIDOTE_INIT_CACHE"
    else
        source <(antidote init) | tee "$ANTIDOTE_INIT_CACHE" >/dev/null 2>&1 || source <(antidote init)
    fi

    # Set ZSH to antidote's oh-my-zsh installation
    ANTIDOTE_HOME="$(antidote home)"
    export ZSH="$ANTIDOTE_HOME/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh"

    # Load plugins from .zsh_plugins.txt (suppress verbose output)
    if [[ -f ~/.zsh_plugins.txt ]]; then
        # Cache plugin bundle output to avoid displaying it
        local bundle_cache="${XDG_CACHE_HOME:-$HOME/.cache}/antidote-bundle.zsh"
        if [[ ! -f "$bundle_cache" ]] || [[ "$bundle_cache" -ot ~/.zsh_plugins.txt ]]; then
            antidote bundle < ~/.zsh_plugins.txt > "$bundle_cache" 2>/dev/null
        fi
        source "$bundle_cache" 2>/dev/null
    fi

    # Conditionally load brew plugin only on macOS
    if [[ "$OSTYPE" == darwin* ]]; then
        local brew_cache="${XDG_CACHE_HOME:-$HOME/.cache}/antidote-bundle-brew.zsh"
        if [[ ! -f "$brew_cache" ]]; then
            antidote bundle robbyrussell/oh-my-zsh path:plugins/brew > "$brew_cache" 2>/dev/null
        fi
        source "$brew_cache" 2>/dev/null
    fi
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
  git branch -a | egrep -v "(^\*|master|main|origin)" | xargs -n 1 git branch -d
}

# ============================================================================
# AWS SSO Check - Deferred to background for faster startup
# ============================================================================
# Run AWS check in background to avoid blocking shell startup
# Only runs once per session and only in interactive shells
if [[ -o interactive ]] && command -v aws &> /dev/null && [[ -z "$AWS_CHECK_DONE" ]]; then
  export AWS_CHECK_DONE=1
  # Run in background to avoid blocking startup
  (aws sts get-caller-identity --profile default > /dev/null 2>&1 || {
    # Only show message if not logged in (avoid noise if command fails for other reasons)
    if ! aws sts get-caller-identity --profile default > /dev/null 2>&1; then
      echo "AWS SSO: Not logged in (run 'ssologin' to authenticate)" >&2
    fi
  }) &!
fi

# ============================================================================
# GitHub Token - Cached to avoid repeated calls
# ============================================================================
# Only set if gh is available and token not already set
if [[ -o interactive ]] && command -v gh &> /dev/null && [[ -z "$GH_TOKEN" ]]; then
  # Cache token in a file to avoid calling gh on every shell start
  local gh_token_cache="${XDG_CACHE_HOME:-$HOME/.cache}/gh-token"
  if [[ -f "$gh_token_cache" ]] && [[ "$gh_token_cache" -nt "$(which gh)" ]]; then
    export GH_TOKEN="$(cat "$gh_token_cache" 2>/dev/null)"
  else
    export GH_TOKEN=$(gh auth token 2>/dev/null || echo "")
    [[ -n "$GH_TOKEN" ]] && echo "$GH_TOKEN" > "$gh_token_cache" 2>/dev/null
  fi
fi

# ============================================================================
# Cursor Agent shell integration (commented out as in original)
# ============================================================================
#if [[ -o interactive ]] && [[ -x "$HOME/.local/bin/cursor-agent" ]]; then
#  eval "$(~/.local/bin/cursor-agent shell-integration zsh)"
#fi

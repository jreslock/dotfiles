# Optimized .zshrc - Fast startup with all functionality preserved

# Skip duplicate PATH entries to prevent PATH bloat
typeset -U path PATH

# Enable zsh completion system (only if not already loaded)
if [[ -z "$_comp_setup" ]]; then
    autoload -U +X bashcompinit && bashcompinit
    autoload -U +X compinit && compinit
fi

# Homebrew configuration (macOS only) - optimized
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

# Essential PATH additions
path=("$HOME/.docker/bin" "$HOME/.local/bin" $path)

# Load antidote plugin manager (with error handling)
if [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
    source "$HOME/.antidote/antidote.zsh"
    
    # Initialize antidote
    source <(antidote init)
    
    # Set ZSH to antidote's oh-my-zsh installation
    ANTIDOTE_HOME="$(antidote home)"
    export ZSH="$ANTIDOTE_HOME/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh"
    
    # Load plugins from .zsh_plugins.txt
    if [[ -f ~/.zsh_plugins.txt ]]; then
        antidote bundle < ~/.zsh_plugins.txt
    fi
    
    # Conditionally load brew plugin only on macOS
    if [[ "$OSTYPE" == darwin* ]]; then
        antidote bundle robbyrussell/oh-my-zsh path:plugins/brew
    fi
fi

# Aliases (preserved exactly as they were)
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

# Functions (preserved exactly as they were)
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

# Cursor Agent function (preserved exactly as it was)
function ca() {
    # --- Configuration ---
    local PERSONA_FILE="$HOME/.config/cursor/AGENTS.md"

    # --- Pre-flight Check ---
    if [[ ! -f "$PERSONA_FILE" ]]; then
        echo "Persona file not found at $PERSONA_FILE" >&2
        return 1
    fi

    # --- Argument Handling ---
    if [[ $# -eq 0 ]]; then
        echo "Usage:"
        echo "  ca <uuid> \"<message>\"     # Resume an existing thread"
        echo "  ca \"<first_message>\"      # Start a new thread"
        return 1
    fi

    local first_arg="$1"
    # This regex matches the standard UUID format (e.g., af756db5-ba87-4d1d-a725-667ba062e014)
    local uuid_regex='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'

    # --- Core Logic ---
    if [[ "$first_arg" =~ $uuid_regex ]]; then
        # The first argument IS a UUID, so we resume.
        local uuid="$1"
        local user_message="${@:2}" # The message is everything after the UUID
        
        echo "Resuming thread: $uuid"
        cursor-agent --resume="$uuid" "$user_message"
    else
        # The first argument is NOT a UUID, so we start a new chat.
        local user_message="$*" # The message is the entire command line
        
        echo "Starting new thread with persona..."
        local full_message
        full_message="$(cat "$PERSONA_FILE")

${user_message}"
        cursor-agent "$full_message"
    fi
}

# Simple AWS SSO check - only once per session, no complex locking
if [[ -o interactive ]] && command -v aws &> /dev/null && [[ -z "$AWS_CHECK_DONE" ]]; then
  export AWS_CHECK_DONE=1
  check_logged_in
fi

# GitHub token (only if gh is available and not already set)
if [[ -o interactive ]] && command -v gh &> /dev/null && [[ -z "$GH_TOKEN" ]]; then
  export GH_TOKEN=$(gh auth token 2>/dev/null || echo "")
fi

# Powerlevel10k instant prompt (load early for better performance)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Cursor Agent shell integration (with proper path check)
if [[ -o interactive ]] && [[ -x "$HOME/.local/bin/cursor-agent" ]]; then
  eval "$(~/.local/bin/cursor-agent shell-integration zsh)"
fi

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
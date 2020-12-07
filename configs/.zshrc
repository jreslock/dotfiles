export EDITOR="vim"
export DISABLE_MAGIC_FUNCTIONS=true
export GROOVY_HOME=/usr/local/opt/groovy/libexec
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

ANTIBODY_HOME="$(antibody home)"
export ZSH="$ANTIBODY_HOME"/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh

source $ZSH/oh-my-zsh.sh
source <(antibody init)
antibody bundle < ~/.zsh_plugins

alias c="clear"
alias pull="git pull"
alias push="git push"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias rr="cd $(git rev-parse --show-toplevel)"

GPG_TTY=$(tty)
export GPG_TTY
export SSH_AUTH_SOCK=/$HOME/.gnupg/S.gpg-agent.ssh

function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# makana autocomplete setup
MAKANA_AC_ZSH_SETUP_PATH=/Users/jreslock/Library/Caches/makana/autocomplete/zsh_setup && test -f $MAKANA_AC_ZSH_SETUP_PATH && source $MAKANA_AC_ZSH_SETUP_PATH;

export PYENV_ROOT=$HOME/.pyenv

if command -v pyenv 1>/dev/null 2>&1; 
  then 
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jreslock/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/jreslock/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jreslock/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/jreslock/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/usr/local/sbin:$PATH"

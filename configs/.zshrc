#Set some vars

export EDITOR='code'
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:/usr/local/bin:/usr/local/sbin:$PATH"
export DISABLE_MAGIC_FUNCTIONS=true
# Activate virtualenv

export PYENV_VIRTUALENV_DISABLE_PROMPT=1
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv activate pydev3

# Source Antigen
source ~/antigen.zsh

# Tell Antigen to use oh-my-zsh
antigen use oh-my-zsh
antigen theme denysdovhan/spaceship-prompt

# Install plugins
antigen bundles <<EOBUNDLES
    autojump
    aws
    brew
    common-aliases
    compleat
    docker
    encode64
    git
    git-extras
    gpg-agent
    jsontools
    pip
    python
    pyenv
    sbt
    scala
    terraform
    zsh-users/zsh-completions
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-history-substring-search ./zsh-history-substring-search.zsh
EOBUNDLES

# Set aliases
alias o="code"
alias c="clear"
alias pull="git pull"
alias push="git push"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"

GPG_TTY=$(tty)
export GPG_TTY
export SSH_AUTH_SOCK=/$HOME/.gnupg/S.gpg-agent.ssh

# Done
antigen apply
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

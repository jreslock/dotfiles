# Source Antigen
source /usr/local/share/antigen/antigen.zsh

# Tell Antigen to use oh-my-zsh
antigen use oh-my-zsh

# Install plugins
antigen bundles <<EOBUNDLES
    autojump
    brew
    common-aliases
    command-not-found
    compleat
    docker
    git
    git-extras
    mvn
    osx
    pip
    python
    ruby
    thefuck
    vagrant
    virtualenvwrapper
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-history-substring-search ./zsh-history-substring-search.zsh
EOBUNDLES

#Set some vars
export EDITOR="vim"
export PATH="/Users/jr186055/bins:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin"
export WORKON_HOME=~/Envs

# Set aliases
alias ssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
alias aws="noglob aws"
alias o="vim"
alias woi="workon infradev"
alias c="clear"
alias cdw="cd ~/work"
alias cdp="cd ~/playground"
alias tc4h="cd ~/work/tc4h"
alias tdmc="cd ~/work/tdmc"
alias kk="cd ~/work/kubekit"

# Load a theme
antigen theme tonyseek/oh-my-zsh-seeker-theme seeker

# Done
antigen apply
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# The next line updates PATH for the Google Cloud SDK.
if [ -f /Users/jr186055/Downloads/google-cloud-sdk/path.zsh.inc ]; then
  source '/Users/jr186055/Downloads/google-cloud-sdk/path.zsh.inc'
fi


GPG_TTY=$(tty)
export GPG_TTY
if [ -f "${HOME}/.gpg-agent-info" ]; then
      . "${HOME}/.gpg-agent-info"
      export GPG_AGENT_INFO
      export SSH_AUTH_SOCK
fi

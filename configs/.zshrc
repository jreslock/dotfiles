# Source Antigen
source /usr/local/share/antigen/antigen.zsh

# Tell Antigen to use oh-my-zsh
antigen use oh-my-zsh

# Install plugins
antigen bundles <<EOBUNDLES
    git
    python
    pip
    virtualenvwrapper
    command-not-found
    common-aliases
    brew
    brew-cask
    docker
    mvn
    ruby
    ssh-agent
    thefuck
    vagrant
    zsh-users/zsh-syntax-highlighting
EOBUNDLES

#Set some vars
export EDITOR="vim"
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin"
export WORKON_HOME=~/Envs

# Set aliases
alias ssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
alias o="vim"
alias woi="workon infradev"
alias woh="workon hfab"
alias c="clear"
alias cdw="cd ~/work"
alias cdp="cd ~/playground"
alias tc4h="cd ~/work/tc4h"
alias tdmc="cd ~/work/tdmc"

# Load a theme
antigen theme tonyseek/oh-my-zsh-seeker-theme seeker

# Done
antigen apply
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

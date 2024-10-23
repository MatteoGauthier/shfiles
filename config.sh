export LANG="en_US.UTF-8"

# export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --no-ignore -g '!{node_modules/,.git/,Library}'"
# export FZF_DEFAULT_COMMAND="rg --files --hidden --follow"
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --smart-case -g '!node_modules' -g '!.git' -g '!Library'"
export FZF_DEFAULT_OPTS='--multi --no-height --extended'

export HISTSIZE=50000
export SAVEHIST=50000
export HISTTIMEFORMAT="%d/%m/%y %T "

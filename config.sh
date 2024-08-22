export LANG="en_US.UTF-8"

# export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --no-ignore -g '!{node_modules,.git,Library}'"
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --no-ignore -g '!{node_modules,.git,Library} --max-depth 1'"

export HISTSIZE=50000
export SAVEHIST=50000
export HISTTIMEFORMAT="%d/%m/%y %T "

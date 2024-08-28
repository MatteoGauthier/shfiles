
alias y="yarn"
alias modern_tsconfig="curl -s https://gist.githubusercontent.com/MatteoGauthier/3a5572e8685e9d7d3388c6ab4557474e/raw/7a16b2ed4f60b21ad91cd82b05ddecc907c31f0f/tsconfig.json > tsconfig.json"
alias pnpx="pnpm dlx"
alias jsonbat="json_pp | bat -l json --style=\"plain\""
alias tempfile='temp_file=$(mktemp) && nano "$temp_file" && echo "$temp_file"'
alias search='pattern=$(cat) tempfile && echo $pattern'

alias p="pnpm"

alias prettyjson="node -r fs -e \"console.log(JSON.stringify(JSON.parse(fs.readFileSync('/dev/stdin', 'utf-8')), null, 4));\""
alias logjson="node -r fs -e \"console.log(JSON.stringify(JSON.parse(fs.readFileSync('/dev/stdin', 'utf-8'))));\""
alias logstdin="node -r fs -e \"console.log((fs.readFileSync('/dev/stdin', 'utf-8')));\""
alias nodearch="node -p \"console.log(process.arch);\""
alias getrepos="gh api \"users/MatteoGauthier/repos?sort=pushed\" --jq '.[].name' | logstdin"

alias publicip="curl -s http://checkip.dyndns.org/ | sed 's/[a-zA-Z<>/ :]//g'"
alias localip="ipconfig getifaddr en0"

alias e="eza -l --icons -s date"
alias ez='eza -l --icons -s date'

alias lg='lazygit'
alias lzd='lazydocker'
alias dps='docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Image}}"'

alias h='echo -e "$(history | sort -r | awk '\''{$1=""; print substr($0,2)}'\'' | fzf +s --exact --bind '\''ctrl-y:execute-silent(echo -n {+} | pbcopy)'\'' )"'
alias xcd='cd "$(xplr --print-pwd-as-result)"'


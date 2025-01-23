
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

alias beep="afplay /System/Library/Sounds/Glass.aiff"


# Open a file in the default macOS app
function fzfo() {
    local file
    file=$(fzf) && open "$file"
}


readenv() {
  local filePath="${1:-.env}"

  if [ ! -f "$filePath" ]; then
    # silently be done
    # put some error / echo if you prefer non-silent errors
    return 0
  fi

  echo "Reading $filePath"
  while read -r line; do
    if [[ "$line" =~ ^\s*#.*$ || -z "$line" ]]; then
      continue
    fi

     # Split the line into key and value. Trim whitespace on either side.
    key=$(echo "$line" | cut -d '=' -f 1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    value=$(echo "$line" | cut -d '=' -f 2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Leaving the below here... normally this works, but if you have something like
    # FOO="  string with leading and trailing  "
    # then the leading / trailing spaces are deleted. FOO="a word", FOO='a word', and FOO=a word all generally work
    # so leave the quotes
    # Remove single quotes, double quotes, and leading/trailing spaces from the value
    # value=$(echo "$value" | sed -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//' -e 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Export the key and value as environment variables
    # echo "$key=$value"
    export "$key=$value"

  done < "$filePath"
}

qrcode () {
  local input="$*"
  [ -z "$input" ] && local input="@/dev/stdin"
  curl -d "$input" https://qrcode.show
}

qrsvg () {
  local input="$*"
  [ -z "$input" ] && local input="@/dev/stdin"
  curl -d "${input}" https://qrcode.show -H "Accept: image/svg+xml"
}

qrserve () {
  local port=${1:-8080}
  local dir=${2:-.}
  local ip="$(ifconfig | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | fzf --prompt IP:)" \
    && echo http://$ip:$port | qrcode \
    && python -m http.server $port -b $ip -d $dir
}

# Not working !! @xxx @todo
function frg {
    result=$(rg --ignore-case --color=always --line-number --no-heading "$@" |
        fzf --ansi \
            --color 'hl:-1:underline,hl+:-1:underline:reverse' \
            --delimiter ':' \
            --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
    file=${result%%:*}
    linenumber=$(echo "${result}" | cut -d: -f2)
    if [[ -n "$file" ]]; then
        $EDITOR +"${linenumber}" "$file"
    fi
}

function lk {
  cd "$(walk --icons "$@")"
}


function zz() {
  local dir=$(
    zoxide query --list --score | sort -rn | while read -r line; do
      score=$(echo "$line" | awk '{print $1}')                                     # Extract score
      filepath=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^[[:space:]]*//') # Extract file path

      if [ -e "$filepath" ]; then
        mod_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$filepath") # Get modified date (for macOS)

        # Apply color formatting and display in correct order
        echo -e "\033[1;32m$filepath\033[0m \033[1;34m$mod_date\033[0m \033[1;33m$score\033[0m"
      fi
    done |
      fzf --layout reverse --ansi --info inline \
        --nth 1 --query "$*" \
        --bind 'enter:become:echo {1}'
  ) && cd "$dir"
}

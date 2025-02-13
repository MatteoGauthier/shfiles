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
        # Get modified date (works on both macOS and Linux), because on macOS the stat application is from the FreeBSD distribution, and on Ubuntu it's coreutils of GNU
        if [[ "$OSTYPE" == "darwin"* ]]; then
          mod_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$filepath") # macOS
        else
          mod_date=$(stat -c "%y" "$filepath" | cut -d'.' -f1) # Linux
        fi

        # Apply color formatting and display in correct order
        echo -e "\033[1;32m$filepath\033[0m \033[1;34m$mod_date\033[0m \033[1;33m$score\033[0m"
      fi
    done |
      fzf --layout reverse --ansi --info inline \
        --nth 1 --query "$*" \
        --bind 'enter:become:echo {1}'
  ) && cd "$dir"
}

convert_to_mp4() {
    # Check for flags
    local download_flag=false
    local input_file=""
    
    # Parse arguments
    for arg in "$@"; do
        if [[ "$arg" == "--dl" || "$arg" == "--download" ]]; then
            download_flag=true
        else
            input_file="$arg"  # Capture the input file
        fi
    done

    # Check if the input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: File '$input_file' does not exist."
        return 1
    fi

    # Gather input file information using ffprobe
    local input_file_size=$(stat -f%z "$input_file")  # Get input file size in bytes
    local input_file_type=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$input_file")
    
    # Determine output directory
    local output_dir
    if $download_flag; then
        output_dir="$HOME/Downloads"
    else
        output_dir="$(dirname "$input_file")"
    fi

    # Get the base name and output file name
    local base_name="$(basename "$input_file" | sed 's/\.[^.]*$//')"  # Remove extension
    local output_file="$output_dir/${base_name}.mp4"

    # Check if the output file already exists and modify the filename if necessary
    local counter=1
    while [[ -f "$output_file" ]]; do
        output_file="$output_dir/${base_name}_$counter.mp4"
        ((counter++))
    done

    # Convert the video to MP4 using ffmpeg
    ffmpeg -i "$input_file" -c:v libx264 -c:a aac -strict experimental -b:a 192k "$output_file"

    # Check if ffmpeg succeeded
    if [[ $? -eq 0 ]]; then
        # Get output file size
        local output_file_size=$(stat -f%z "$output_file")

        # Calculate size reduction
        local size_reduction=$((input_file_size - output_file_size))
        local size_reduction_percentage=0
        if [[ $input_file_size -gt 0 ]]; then
            size_reduction_percentage=$(awk "BEGIN {printf \"%.2f\", ($size_reduction/$input_file_size)*100}")
        fi

        # Output information
        echo "Successfully converted '$input_file' to '$output_file'."
        echo "Input File Type: $input_file_type"
        echo "Input File Size: $((input_file_size / 1024)) KB"
        echo "Output File Size: $((output_file_size / 1024)) KB"
        echo "Size Reduction: $size_reduction bytes ($size_reduction_percentage%)"
    else
        echo "Error: Conversion failed."
        return 1
    fi
}

function jsont(){
  jq -r '(.[0] | ([keys[] | .] |(., map(length*"-")))), (.[] | ([keys[] as $k | .[$k]])) | @tsv' | column -t -s $'\t'
}

# fzf cd
function fcd() {
  FZF_DEFAULT_COMMAND="fd --type d"

  cd "$(fzf "$@")"
}

function _rgi_base() {
    # Initial search pattern is passed as argument
    local pattern="${1:-}"
    local rg_args="${2:-}"
    
    echo $pattern
    
    # Use ripgrep to search and pipe into fzf
    local selected=$(
        rg $rg_args --color=always --line-number --no-heading --smart-case "${pattern}" |
            fzf --ansi \
                --color 'hl:-1:underline,hl+:-1:underline:reverse' \
                --delimiter ':' \
                --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'ctrl-p:change-preview-window(hidden|)' \
                --bind 'ctrl-i:execute(bat --color=always --style=numbers --highlight-line {2} {1})' \
                --header 'CTRL-P to toggle preview window, CTRL-I to open in editor' \
                --exact
    )

    # If selection was made, open in editor
    if [[ -n "$selected" ]]; then
        local file=$(echo "$selected" | cut -d':' -f1)
        local line=$(echo "$selected" | cut -d':' -f2)
        
        # Handle different editors
        if [[ "$EDITOR" == *"code"* ]] || [[ "$EDITOR" == *"cursor"* ]]; then
            # VS Code/Cursor specific handling
            "$EDITOR" --goto "$file:$line"
        else
            # Default editor handling
            ${EDITOR:-vim} +"${line}" "$file"
        fi
    fi
}

function rgi() {
    _rgi_base "$1" ""
}

function rgia() {
    _rgi_base "$1" "-uuu"
}

dlogs() {
  local layout=${1:-default}
  local preview_cmd='docker logs --timestamps -n 300 $(echo {} | cut -d" " -f1) 2>&1 | bat --style=plain --color=always -l log'
  local preview_opts="--preview-window=right:60%:wrap"

  docker ps --format='table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}' | \
    tail -n +2 | \
    fzf --header="Press CTRL-P to switch layout, ENTER to follow logs" \
        --preview "$preview_cmd" \
        $preview_opts \
        --bind 'ctrl-l:toggle-preview-wrap' \
        --bind 'ctrl-p:change-preview-window(right,60%|down,80%)' \
        --bind 'enter:execute(docker logs -f --timestamps $(echo {} | cut -d" " -f1))' \
        --color 'preview-border:bright-black'
}

# dreamzsh/plugins/extract/plugin.zsh

extract() {
  if (( $# == 0 )); then
    print -u2 -- "usage: extract <archive> [archive...]"
    return 1
  fi

  local file
  for file in "$@"; do
    if [[ ! -f "$file" ]]; then
      print -u2 -- "extract: '$file' is not a valid file"
      continue
    fi

    local dir="${file%.*}"
    dir="${dir%.tar}"
    dir="${dir%.tgz}"

    mkdir -p "$dir" || continue

    case "${file:l}" in
      *.tar.bz2|*.tbz2) tar -xjf "$file" -C "$dir" ;;
      *.tar.gz|*.tgz)   tar -xzf "$file" -C "$dir" ;;
      *.tar.xz|*.txz)   tar -xJf "$file" -C "$dir" ;;
      *.tar.zst)        tar --zstd -xf "$file" -C "$dir" ;;
      *.tar)            tar -xf "$file" -C "$dir" ;;
      *.gz)             gunzip -c "$file" > "$dir/$(basename "$file" .gz)" ;;
      *.bz2)            bunzip2 -c "$file" > "$dir/$(basename "$file" .bz2)" ;;
      *.xz)             unxz -c "$file" > "$dir/$(basename "$file" .xz)" ;;
      *.zip|*.jar|*.war|*.ear) unzip -q "$file" -d "$dir" ;;
      *.7z)             7z x "$file" -o"$dir" ;;
      *.rar)            unrar x "$file" "$dir/" ;;
      *.zst)            zstd -d "$file" -o "$dir/$(basename "$file" .zst)" ;;
      *) print -u2 -- "extract: '$file' cannot be extracted (unknown format)" ; continue ;;
    esac

    print -r -- "extract: '$file' -> '$dir'"
  done
}

alias x='extract'

compdef '_files -g "*.(tar.bz2|tbz2|tar.gz|tgz|tar.xz|txz|tar.zst|tar|gz|bz2|xz|zip|jar|war|ear|7z|rar|zst)"' extract 2>/dev/null || true

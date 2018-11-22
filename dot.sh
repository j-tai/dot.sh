#!/bin/bash
SCRIPT="$(basename "$0")"
# Exit code; changed to 1 when an error occurs.
EXIT=0

# Check that $DOTROOT is set and non-empty.
if [ -z "$DOTROOT" ]; then
    echo >&2 "$SCRIPT: please set \$DOTROOT to the dotfiles root"
    exit 2
fi

# Check that 'dotfiles' exists.
if [ ! -e "$DOTROOT/dotfiles" ]; then
    echo >&2 "$SCRIPT: $DOTROOT/dotfiles: file not found"
    exit 2
fi

check () {
    if [ -L "$HOME/$1" ]; then
        if [ "$(readlink "$HOME/$1")" != "$DOTROOT/$1" ]; then
            # Incorrect symlink
            echo >&2 "fixing: $1"
            rm "$HOME/$1"
            ln -s "$DOTROOT/$1" "$HOME/$1"
        fi
        echo "$1"
    else
        create "$1"
    fi
}

create () {
    # Attempt to create a symlink.
    if [ -e "$HOME/$1" -a ! -L "$HOME/$1" -a ! -e "$DOTROOT/$1" ]; then
        echo >&2 "moving and symlinking: ~/$1"
        mkdir -p "$(dirname "$DOTROOT/$1")"
        mv "$HOME/$1" "$DOTROOT/$1"
        ln -s "$DOTROOT/$1" "$HOME/$1"
        echo "$1"
    elif [ -e "$HOME/$1" -o -L "$HOME/$1" ]; then
        echo >&2 "$SCRIPT: $1: cannot create because '~/$1' exists"
        EXIT=1
    else
        echo >&2 "creating: ~/$1"
        mkdir -p "$(dirname "$HOME/$1")"
        ln -s "$DOTROOT/$1" "$HOME/$1"
        echo "$1"
    fi
}

remove () {
    # Attempt to remove a symlink.
    if [ ! -e "$HOME/$1" -a ! -L "$HOME/$1" ]; then
        # File was already removed
        :
    elif [ ! -L "$HOME/$1" ]; then
        echo >&2 "$SCRIPT: $1: cannot remove because '~/$1' was altered"
        echo "$1"
        EXIT=1
    else
        echo >&2 "removing: ~/$1"
        rm "$HOME/$1"
    fi
}

main () {
    # Run main algorithm. Reads from fd 3 for existing dotfiles and fd
    # 4 for new dotfiles. Writes to fd 1 (stdout) for the new dotfiles
    # cache.
    local have want ok=false
    read -u 3 -r have || ok=true
    read -u 4 -r want || ok=true
    while [ "$ok" = false ]; do
        if [ "$have" = "$want" ]; then
            check "$have"
            read -u 3 -r have || ok=true
            read -u 4 -r want || ok=true
        elif [ "$have" '<' "$want" ]; then
            remove "$have"
            read -u 3 -r have || ok=true
        else
            create "$want"
            read -u 4 -r want || ok=true
        fi
    done
    if [ -n "$have" -a -z "$want" ]; then
        # More haves
        while true; do
            remove "$have"
            read -u 3 -r have || break
        done
    elif [ -z "$have" -a -n "$want" ]; then
        # More wants
        while true; do
            create "$want"
            read -u 4 -r want || break
        done
    fi
}

# Create ~/.dotfiles if it doesn't yet exist.
>> "$HOME/.dotfiles"
main 3< "$HOME/.dotfiles" 4< <(sort "$DOTROOT/dotfiles") > "$HOME/.dotfiles.new"
mv "$HOME/.dotfiles.new" "$HOME/.dotfiles"
exit "$EXIT"

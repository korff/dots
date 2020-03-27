#!/bin/sh

set -e
set -u

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

install_package() {
    echo -n "$1 is missing. Want to install? (y/n) " >&2
    stty_config_saved=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $stty_config_saved && echo
    if echo "$answer" | grep -iq "^y"
    then
        # Debian, ubuntu, ...
        if [ -x "$(command -v apt-get)" ]
        then
            sudo apt-get install $1 -y

        # macOS, ...
        elif [ -x "$(command -v brew)" ]
        then
        brew install $1

        # RHEL, CentOS, ...
        elif [ -x "$(command -v yum)" ]
        then
            sudo pkg install $1

        # ...
        elif [ -x "$(command -v pkg)" ]
        then
            sudo pkg install $1

        # Arch, ...
        elif [ -x "$(command -v pacman)" ]
        then
            sudo pacman -S $1

        else
            echo Cannot detect package manager! Install $1 run this script again. 
        fi 
    fi
}

check_package() {
    echo Checking for $1
    ! [ -x "$(command -v $1)" ] && install_package $1 || echo "$1 already installed."
}

abort() {
    echo Aborting!
    exit 0
}

echo Setting up terminal envirionment

echo "Continue? (y/n)"
stty_config_saved=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $stty_config_saved
echo "$answer" | grep -iq "^y" || abort

# The packages
check_package ctags
echo
check_package vim
echo
check_package tmux
echo

# Hook up the config files
printf "so $script_path/vim/vimrc" > ~/.vimrc
if [ ! -d $HOME/.vim/bundle ]
then
    echo Creating symbolic link: ln -s $script_path/vim/bundle ~/.vim/
    ln -s $script_path/vim/bundle ~/.vim/
fi
printf "source-file $script_path/tmux/tmux.conf" > ~/.tmux.conf


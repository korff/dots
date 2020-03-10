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
        if ! [ -x "$(command -v $1)" ]; then
            install_package $1
        else
            echo "$1 already installed."
        fi
    }

echo Setting up terminal envirionment

echo "Continue? (y/n)"
stty_config_saved=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $stty_config_saved
if echo "$answer" | grep -iq "^y" ;then
    echo 
else
    echo Aborting!
    exit 0
fi

# The packages
check_package vim
echo
check_package tmux
echo

# Hook up the config files
printf "so $HOME/.setup/vim/vimrc" > ~/.vimrc
printf "source-file $HOME/.setup/tmux/tmux.conf" > ~/.tmux.conf


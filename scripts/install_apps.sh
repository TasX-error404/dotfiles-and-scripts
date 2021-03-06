#! /usr/bin/env bash

# delete the app you don't need

# --------------------------------------------
# apps
# --------------------------------------------

_basic=(
    #vim # replace with gvim in graphical env
    arch-install-scripts
    axel
    curl
    elinks
    git
    tar
    tmux
    wget
)

# basic Chinese fonts
_fonts=(
    adobe-source-code-pro-fonts
    adobe-source-han-sans-cn-fonts
    adobe-source-han-serif-cn-fonts
    opendesktop-fonts 
    otf-fira-mono
    ttf-anonymous-pro
    ttf-arphic-ukai
    ttf-arphic-uming 
    ttf-fira-mono
    ttf-freefont
    ttf-gentium
    ttf-hack
    ttf-hannom
    ttf-inconsolata
    ttf-linux-libertine
    wqy-bitmapfont
    wqy-zenhei
)

_cli=(
    arandr
    aria2
    conky
    compton
    cronie
    docker
    fortune-mod
    cowsay
    dunst
    feh
    go
    mlocate
    neofetch
    nginx
    npm
    p7zip
    python2
    python2-pip
    python3
    python-pip
    rabbitmq
    screenfetch
    scrot
    shadowsocks
    tig
    fzf
    unrar
    xclip
    xsel
    youtube-dl
    zsh
)

_desktop=(
    # thunar 
    # thunar-archive-plugin
    # thunar-media-tags-plugin
    # thunar-volman
    chromium
    fbreader
    libreoffice
    lxappearance
    pcmanfm
    thunderbird
    volumeicon
    xfce4-terminal
)

_aur=(
    # wewechat
    # wps-office
    acroread
    acroread-fonts
    alacritty-scrollback-git
    apvlv
    bmenu
    crossover
    electronic-wechat
    oh-my-zsh-git
    teamviewer
)

# appearance
_themes=(
    xcursor-simpleandsoft
    ark-icon-theme
    papirus-icon-theme
)
_aur_themes=(
    vertex-themes
    paper-gtk-theme-git
    paper-icon-theme-git
)

# vim 
_required_by_vim=(
    flake8    
    autopep8
    prettier
    ack
)
_required_by_vim_aur=(
    #gitlint
    #python-vint
    shfmt
    sqlint
    python-proselint
)

# pip
_py_general=()


# --------------------------------------------
# Manually install
# --------------------------------------------

# manually install pkg from aur
# $1    the app to install
install_aur_app() {
    local aur_tmp=/tmp/_my_aur
    [[ -z "$1" ]] && exit_with_msg "Invalid argument: $1"
    local app=$1
    do_install git

    mkdir -p $aur_tmp 
    cd $aur_tmp 
    git clone "https://aur.archlinux.org/${app}.git" $app 
    cd $app 
    makepkg -sri --noconfirm
    cd ~
    rm -rf $aur_tmp
}

install_yay() {
    command -v yay >/dev/null && return
    do_install 'go'
    install_aur_app 'yay'
}

install_yaourt() {
    command -v yaourt >/dev/null && return
    install_aur_app 'package-query'
    install_aur_app 'yaourt'
}

install_nerd_fonts() {
    local target_dir='/usr/share/fonts/nerd'
    local _tmp='/tmp/monaco-nerd-fonts'
    sudo mkdir -p $target_dir
    ls ${target_dir}/*Monaco* >/dev/null 2>&1 && echo 'Monaco Nerd Fonts already exists.' && return
    git clone https://github.com/Karmenzind/monaco-nerd-fonts $_tmp
    cd $_tmp/fonts && rm -rf *Windows* && sudo cp ./*tf $target_dir 
    cd ~
    rm -rf $_tmp
}

install_ranger_and_plugins () {
    echo "Install ranger and plugins? (Y/n)"
    check_input yn
    if [[ $ans = 'y' ]]; then
        # ranger and basic config
        do_install ranger
        ranger --copy-config=all
        # devicons
        local clonedir=/tmp/ranger_devicons
        [[ -d $clonedir ]] && rm -rf $clonedir
        git clone https://github.com/alexanderjeurissen/ranger_devicons $clonedir
        cd $clonedir
        make install
        cd ~
        rm -rf $clonedir
    fi
}

# --------------------------------------------

# official
do_install ${_basic[*]} ${_fonts[*]} ${_cli[*]} ${_desktop[*]} ${_themes[*]} ${_required_by_vim[*]}
sudo pacman -Sc 

# aur
install_yay
aur_helper=yay
$aur_helper -S -v --needed --noconfirm ${_aur[*]} ${_aur_themes[*]} ${_required_by_vim_aur[*]}
$aur_helper -Sc

# others
install_ranger_and_plugins
install_nerd_fonts


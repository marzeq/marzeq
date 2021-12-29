#!/bin/bash

###############################################################################################################
# This script is a little installer for my dotfiles, programs I use frequently, and other random stuff I need #
# DISCLAIMER: this script is NOT an installer script, it's meant to be run after a fresh install!             #
###############################################################################################################

# directory the script resides in
a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}
currentdir=$a

###############################################################################################################
#                                COPY DOTFILES TO HOME DIRECTORY AND LOAD THEM                                #
###############################################################################################################

cp "$currentdir"/.bashrc "$HOME"/.bashrc
cp "$currentdir"/.aliasrc "$HOME"/.aliasrc
mkdir -p "$HOME"/.config/nvim
cp "$currentdir"/init.vim "$HOME"/.config/nvim/init.vim
. "$HOME"/.bashrc


###############################################################################################################
#                                            INSTALL PROGRAMS                                                 #
###############################################################################################################


#######
# yay #
#######

# we'll need this later to install appimagelauncher on arch based distros

if command -v pacman &>/dev/null; then
    if command -v yay &>/dev/null; then
        echo "yay is already installed"
    else
        echo "Installing yay"
        pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay || exit
        makepkg -si
    fi
fi

############
# pacstall #
############

# we'll need this later to install neovim on arch based distros

if command -v apt &>/dev/null; then
	if command -v pacstall &>/dev/null; then
		echo "pacstall is already installed"
	else
		echo "Installing pacstall"
		sudo bash -c "$(curl -fsSL https://git.io/JsADh || wget -q https://git.io/JsADh -O -)"
	fi
fi


####################
# AppImageLauncher #
####################

# we'll need this later to install lunar client

if command -v appimagelauncherd &> /dev/null; then
    echo "AppimageLauncher is already installed"
else
    echo "Installing AppimageLauncher"
    if command -v apt &> /dev/null; then
        sudo add-apt-repository ppa:appimagelauncher-team/stable
        sudo apt update
        sudo apt install appimagelauncher
    elif command -v pacman &> /dev/null; then
        yay -S appimagelauncher
    else
        echo "No supported package manager found for installing AppImageLauncher, please install AppImageLauncher manually: https://github.com/TheAssassin/AppImageLauncher#installation"
        exit 1
    fi
fi

echo ""


##############
# GitHub CLI #
##############

if command -v gh &> /dev/null; then
    echo "The GitHub CLI is already installed"
else
    echo "Installing the GitHub CLI"
    if command -v apt &> /dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh
    elif command -v dnf &> /dev/null; then
        sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        sudo dnf install gh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S github-cli
    else
        echo "No supported package manager found for installing the GitHub CLI, please install the GitHub CLI manually: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
        exit 1
    fi
fi

# auth git credentials with github cli
echo "--------------------------"
echo "SELECT THE DEFAULT OPTIONS"
echo "--------------------------"
echo ""
gh auth login

echo ""


###########
# Discord #
###########

if command -v discord &> /dev/null; then
    echo "Discord is already installed"
else
    echo "Installing Discord"
    if command -v apt &> /dev/null; then
        pacstall -I discord
    elif command -v pacman &> /dev/null; then
        sudo pacman -S discord
    else
        wget -O discord.tar.gz "https://discordapp.com/api/download?platform=linux&format=tar.gz"
        echo "Extracting the downloaded discord.tar.gz file to /opt"
        sudo tar -xvzf discord.tar.gz -C /opt &> /dev/null
        echo "Symlinking /opt/Discord/Discord to /usr/bin/discord"
        sudo ln -s /opt/Discord/Discord /usr/bin/discord
        rm discord.tar.gz
    fi
fi

echo ""


#####################
# Neovim & vim-plug #
#####################

if command -v nvim &> /dev/null; then
    echo "Neovim is already installed"
else
    echo "Installing Neovim"
    if command -v apt &> /dev/null; then
    	pacstall -I neovim
    elif command -v pacman &> /dev/null; then
        sudo pacman -S neovim
    elif command -v dnf &> /dev/null; then
        sudo dnf install neovim
    else
        echo "No supported package manager found for installing Neovim, please install Neovim manually: https://github.com/neovim/neovim"
        exit 1
    fi
    echo ""
    echo "Installing vim-plug"
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

echo ""

######################
# NodeJS through nvm #
######################

echo "Installing NodeJS and nvm"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install node

echo ""

########
# doas #
########

echo "Installing doas"

if command -v pacman &> /dev/null; then
	yay -S doas
else
	if command -v apt &> /dev/null; then
		sudo apt install build-essential make bison flex libpam0g-dev
	elif command -v dnf &> /dev/null; then
		sudo dnf install gcc gcc-c++ make flex bison pam-devel byacc git
	elif command -v yum &> /dev/null; then
		sudo yum install gcc gcc-c++ make flex bison pam-devel byacc git
	elif command -v zypper &> /dev/null; then
		sudo zypper install gcc gcc-c++ make flex bison pam-devel byacc git
	else
		echo "No supported package manager found for installing doas, please install Neovim manually: https://github.com/slicer69/doas#installing-build-tools"
        exit 1
    fi
	git clone https://github.com/slicer69/doas
	cd doas
	make && sudo make install
	cd .. && rm -rf doas
	sudo echo "permit ${USER} as root" > /usr/local/etc/doas.conf
fi

echo ""
	
################
# Lunar Client #
################

read -p "Do you want to install Lunar Client? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    wget -O LunarClient.AppImage "https://launcherupdates.lunarclientcdn.com/Lunar%20Client-2.9.3.AppImage"
    xdg-open LunarClient.AppImage
    echo "!!! SELECT INTEGRATE AND RUN !!!"
    echo "!!! SELECT INTEGRATE AND RUN !!!"
    echo "!!! SELECT INTEGRATE AND RUN !!!"
    echo "After that, you can close the application"
fi

echo ""

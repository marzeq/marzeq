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
mkdir -p "$HOME"/.bin

###############################################################################################################
#                                            INSTALL PROGRAMS                                                 #
###############################################################################################################

read -p "Do you want to install the frequently used programs? (only Arch and Ubuntu are fully supported) [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
	exit
fi

#######
# yay #
#######

# (On Arch only)

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

echo ""

############
# pacstall #
############

# (On Ubuntu only)

if command -v apt &>/dev/null; then
	if command -v pacstall &>/dev/null; then
		echo "pacstall is already installed"
	else
		echo "Installing pacstall"
		sudo bash -c "$(curl -fsSL https://git.io/JsADh || wget -q https://git.io/JsADh -O -)"
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
if [[ $(git config --get credential.https://github.com.helper) ]]; then
	echo "git is already authenticated"
else
	echo "##############################"
	echo "# SELECT THE DEFAULT OPTIONS #"
	echo "##############################"
	echo ""
	gh auth login
fi

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
# Neovim & AstroVim #
#####################

if command -v nvim &> /dev/null; then
    echo "Neovim is already installed"
else
    echo "Installing Neovim"
    if command -v apt &> /dev/null; then
        sudo add-apt-repository ppa:neovim-ppa/stable
        sudo apt-get update
        sudo apt-get install neovim
    elif command -v pacman &> /dev/null; then
        sudo pacman -S neovim
    elif command -v dnf &> /dev/null; then
        sudo dnf install neovim
    else
        echo "No supported package manager found for installing Neovim, please install Neovim manually: https://github.com/neovim/neovim"
        exit 1
    fi
fi

echo ""
echo "Installing AstroVim"
git clone https://github.com/kabinspace/AstroVim ~/.config/nvim
nvim +PackerSync

echo ""
echo "Installing Nerd Fonts (required for AstroVim)"
wget -O CodeNewRoman.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CodeNewRoman.zip"
unzip CodeNewRoman.zip -d ~/.fonts
fc-cache -fv
rm CodeNewRoman.zip
echo "Make sure you set your terminal font to CodeNewRoman!"

echo ""


######################
# NodeJS through nvm #
######################

echo "Installing NodeJS and nvm"

if command -v node &> /dev/null; then
    echo "NodeJS is already installed"
else
	if command -v nvm &> /dev/null; then
		echo "nvm is already installed"
	else
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
		export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
	fi
	nvm install node
fi

echo ""


########
# doas #
########

echo "Installing doas"

if command -v doas &> /dev/null; then
	echo "doas is already installed"
else
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
			echo "No supported package manager found for installing doas, please install doas manually: https://github.com/slicer69/doas#installing-build-tools"
        	exit 1
    	fi
		git clone https://github.com/slicer69/doas
		cd doas
		make && sudo make install
		cd .. && rm -rf doas
		echo "permit ${USER} as root" | sudo tee -a /usr/local/etc/doas.conf
	fi
fi

echo ""


##########
# pfetch #
##########

echo "Installing pfetch"

if command -v pfetch &> /dev/null; then
	echo "pfetch is already installed"
else
	if command -v pacman &> /dev/null; then
		yay -S pfetch
	elif command -v apt &> /dev/null; then
		pacstall -I pfetch-bin
	else
		git clone https://github.com/dylanaraps/pfetch
		mv pfetch/pfetch "$HOME/.local/bin"
		rm -rf pfetch
	fi
fi

echo ""


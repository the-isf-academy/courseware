#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\e[34m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m'
CLEAR_LINE='\r\033[K'
BOLD='\e[1m'
NORMAL='\e[21m'


# Exit if any subcommand fails
#set -e

function set_ownership {
    printf "${CLEAR_LINE} 🔍 ${BLUE}Giving user write permission local directory..."
    DIR=/usr/local/etc
    if [ -d "$DIR" ]; then
        #changing ownership of /usr/local/etc directories
        sudo chown -R $(whoami) $DIR
        #giving user write permission
        chmod u+w $DIR
    fi
}

function macos_version_check {
    # macOS version check, Hombrew require 10.12 or higher
    printf "${CLEAR_LINE} 🔍 ${BLUE}Checking macOS version...${NC}"
    os_version=$( defaults read loginwindow SystemVersionStampAsString )
    vercomp $os_version $1 
    if [[ $? == 2 ]]; then
        printf "${CLEAR_LINE}${RED}You are running macOS verion %s.\n" $os_version
        printf "${RED}Installing Homebrew requires macOS version $1 or higher. Please ask an instructor for help. ${NC}"
        read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        printf "🔍 ${BLUE}Checking system requiremets...${NC}"
    fi
}

function install_xcode  {
    printf "${CLEAR_LINE}${BLUE}Installing Xcode... (this may take a while)${NC}"
    xcode_version=$( xcode-select --version )
    IFS=' ' # space is set as delimiter
    read -ra ADDR <<< "$xcode_version" #parse version number from response
    vercomp ${ADDR[${#ADDR[@]}-1]} $1 
    if [[ $? == 2 ]]; then
        xcode-select --install > /dev/null
        xcode_version=$( xcode-select --version )
        IFS=' ' # space is set as delimiter
        read -ra ADDR <<< "$xcode_version" #parse version number from response
        vercomp ${ADDR[${#ADDR[@]}-1]} $1 
        if [[ $? == 2 ]]; then
            printf "${RED}Message from version request: %s${NC}\n" "$xcode_version"
            printf "${RED}Unexpected output from Xcode installation. Please ask an instructor for help. ${NC}"
            read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            printf "💻 ${BLUE}Installing xcode command line tools...${NC}"
        fi
    fi
}

function install_homebrew {
    # Homebrew installation
    printf "${CLEAR_LINE}${BLUE}Installing Homebrew... (this may take a while)${NC}"
    brew_version=$( brew --version )
    IFS='\n' # new line is set as delimiter
    read -ra ADDR <<< "$brew_version" #parse version line from response
    IFS=' '
    read -ra ADDR1 <<< ${ADDR[0]} #parse version number from top line
    LASTELEM=${#ADDR1[@]}-1
    vercomp ${ADDR1[$LASTELEM]} $1 
    if [[ $? == 2 ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" > /dev/null
        brew_version=$( brew --version )
        IFS='\n' # new line is set as delimiter
        read -ra ADDR <<< "$brew_version" #parse version line from response
        IFS=' '
        read -ra ADDR1 <<< ${ADDR[0]} #parse version number from top line
        LASTELEM=${#ADDR1[@]}-1
        vercomp ${ADDR1[$LASTELEM]} $1 
        if [[ $? == 2 ]]; then
            printf "${RED}Output from version request: %s${NC}\n" "$brew_version"
            printf "${RED}Unexpected output from Homebrew installation. Please ask an instructor for help. ${NC}"
            exit 1
        fi
    fi
}


function install_brew_package {
    printf "${CLEAR_LINE}🔨 ${BLUE}Installing $1...${NC}"
    if ! command -v $1 > /dev/null; then
        if [[ -n $3 ]]; then
            brew cask install &> /dev/null
        else
            brew install $1 &> /dev/null
        fi
    fi
    version=$( $1 --version )
    IFS=' ' # space is set as delimiter
    read -ra ADDR <<< "$version" #parse version number from response
    vercomp ${ADDR[${#ADDR[@]}-1]} $2 
    if [[ $? == 2 ]]; then
        if [[ -n $3 ]]; then
            brew cask upgrade $1 &> /dev/null
        else
            brew upgrade $1 &> /dev/null
        fi
        version=$( $1 --version )
        IFS=' ' # space is set as delimiter
        read -ra ADDR <<< "$version" #parse version number from response
        vercomp ${ADDR[${#ADDR[@]}-1]} $2 
        if [[ $? == 2 ]]; then
            printf "${CLEAR_LINE}${YELLOW}Output from version request: %s${NC}\n" "$version"
            printf "${YELLOW}Expected version $2 or higher. Please ask an instructor for help. ${NC}\n"
            read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            printf "🔨 ${BLUE}Installing $1....${NC}"
        fi
    fi
}

# file system creation
function filesys {
    printf "${CLEAR_LINE}🗂 ${BLUE}Setting up cs9 folder on Desktop...${NC}"
    DIR=/Users/`whoami`/Desktop/cs9/unit_00
    if [ ! -d "$DIR" ]; then
        mkdir -p $DIR

    fi
}

function setup_venv {
    # Setting up virtual environment
    printf "${CLEAR_LINE}🗂  ${BLUE}Creating virtual environment...${NC}"
    DIR=/Users/`whoami`/Desktop/cs9
    cd $DIR
    python3 -m venv env
    printf 'PATH_add env/bin' > .envrc
    FILE=/Users/`whoami`/.bash_profile
    if [ ! -e $FILE ]; then
        printf 'eval "$(direnv hook bash)"' > $FILE
    else
        if ! grep -q 'eval "$(direnv hook bash)"' "$FILE"; then
            printf '\neval "$(direnv hook bash)"' >> $FILE
        fi
    fi
    source ~/.bash_profile
    direnv allow .
}

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

printf "👋  ${BOLD}${PURPLE}Welcome to the CS9 setup script! Running this script will download some\n"
printf "|   new software and get your computer setup up for the class. Some of the\n"
printf "|   steps may take a while to complete.\n"
printf "|   If you get stuck or have any questions, ask a teacher.\n"
printf "|\n"
printf "|   Note: the setup may ask for your password. As a security measure, you\n"
printf "|   won't see any characters when you type it in.${NC}${NORMAL}\n"
read -p "Ready to begin? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

printf "🔍 ${BLUE}Checking system requirements..."
set_ownership
macos_version_check 10.12
printf "${CLEAR_LINE}👍  ${GREEN}System requirements passed!${NC}\n"

printf "💻 ${BLUE}Installing Xcode command line tools...${NC}"
install_xcode 2354
printf "${CLEAR_LINE}👍  ${GREEN}Xcode command line tools installed!${NC}\n"

printf "🍺 ${BLUE}Installing Homebrew...${NC}"
install_homebrew 2.4.8
printf "${CLEAR_LINE}👍  ${GREEN}Homebrew installed!${NC}\n"

printf "🔨 ${BLUE}Installing brew packages...${NC}"
install_brew_package python3 3.7.7
install_brew_package direnv 2.20.2
install_brew_package git 2.27
install_brew_package atom 0 cask
printf "${CLEAR_LINE}👍  ${GREEN}Brew packages installed!${NC}\n"

printf "🗂 ${BLUE}Setting up cs9 folder on Desktop...${NC}"
filesys
setup_venv
printf "${CLEAR_LINE}👍  ${GREEN}cs9 folder created!${NC}\n"

printf "${PURPLE}Your computer is configured! Please restart Terminal. ${NC}\n"
exit 0

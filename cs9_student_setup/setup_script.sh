#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m'

# file system creation
printf "${BLUE}Creating file system...${NC}\n" sudo chown -R $(whoami) /usr/local/etc
cd /Users/`whoami`/Desktop
mkdir -p cs9
cd cs9
mkdir -p unit_00
printf "${GREEN}✓✓✓ File system created!${NC}\n\n\n"

#changing ownership of /usr/local/etc directories
sudo chown -R $(whoami) /usr/local/etc

#giving user write permission
chmod u+w /usr/local/etc

printf "${BLUE}Installing Xcode...${NC}\n"
xcode-select --install
xcode_version=$( xcode-select --version )
if [[ "$xcode_version" =~ "xcode-select version "[2-9][0-9][0-9][0-9]"." ]]; then
  printf "${GREEN}✓✓✓ Xcode installed!${NC}\n\n\n"
else
  printf "${RED}Message from version request: %s${NC}\n" "$xcode_version"
  printf "${RED}Unexpected output from Xcode installation. Please ask an instructor for help. ${NC}"
  read -p "Proceed? [y/n]: " ans
  if [[ $ans == 'n' ]]; then
    exit 1
  fi
fi

# macOS version check, Hombrew require 10.12 or higher
printf "${BLUE}Checking macOS version...${NC}\n"
os_version=$( defaults read loginwindow SystemVersionStampAsString )
printf "You are running macOS verion %s.\n" $os_version
if [[ "$os_version" =~ 10\.1[2-9]\.[0-9]? ]]; then
  printf "${GREEN}✓✓✓ macOS version supported by Homebrew!${NC}\n\n\n"
else
  printf "${RED}Installing Homebrew requires macOS version 10.12 or higher. Please ask an instructor for help. ${NC}"
  read -p "Proceed? [y/n]: " ans
  if [[ $ans == 'n' ]]; then
    exit 1
  fi
fi

# Homebrew installation
printf "${BLUE}Installing Homebrew...${NC}\n"
brew_version=$( brew --version )
if [[ "$brew_version" =~ "Homebrew "2\.[1-9]\.[1-9][0-9]?.? ]]; then
  printf "${GREEN}✓✓✓ Homebrew already installed !${NC}\n\n\n"
else
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew_version=$( brew --version )
  if [[ "$brew_version" =~ "Homebrew "2\.[1-9]\.[1-9][0-9]?.? ]]; then
    printf "${GREEN}✓✓✓ Homebrew installed !${NC}\n\n\n"
  else
    printf "${RED}Output from version request: %s${NC}\n" "$brew_version"
    printf "${RED}Unexpected output from Homebrew installation. Please ask an instructor for help. ${NC}"
    read -p "Proceed? [y/n]: " ans
    if [[ $ans == 'n' ]]; then
      exit 1
    fi
  fi
fi

# python3 installation
printf "${BLUE}Installing python3...${NC}\n"
python3_version=$( python3 --version )
if [[ "$python3_version" =~ "Python "3\.[0-9]\.[0-9]? ]]; then
  printf "${GREEN}✓✓✓ Python3 already installed!${NC}\n\n\n"
else
  brew install python3
  python3_version=$( python3 --version )
  if [[ "$python3_version" =~ "Python "3\.[0-9]\.[0-9]? ]]; then
    printf "${GREEN}✓✓✓ Python3 installed!${NC}\n\n\n"
  else
    printf "${RED}Output from version request: %s${NC}\n" "$python3_version"
    printf "${RED}Unexpected output from Python3 installation. Please ask an instructor for help. ${NC}"
    read -p "Proceed? [y/n]: " ans
    if [[ $ans == 'n' ]]; then
      exit 1
    fi
  fi
fi

# git installation
printf "${BLUE}Installing git...${NC}\n"
git_version=$( git --version )
if [[ "$git_version" =~ "git version "2\.[2-9][0-9]?\.[0-9]? ]]; then
  printf "${GREEN}✓✓✓ git already installed!${NC}\n\n\n"
else
  brew install git
  git_version=$( git --version )
  if [[ "$git_version" =~ "git version "2\.[2-9][0-9]?\.[0-9]? ]]; then
    printf "${GREEN}✓✓✓ git installed!${NC}\n\n\n"
  else
    printf "${RED}Output from version request: %s${NC}\n" "$git_version"
    printf "${RED}Unexpected output from git installation. Please ask an instructor for help. ${NC}"
    read -p "Proceed? [y/n]: " ans
    if [[ $ans == 'n' ]]; then
      exit 1
    fi
  fi
fi

# direnv installation
printf "${BLUE}Installing direnv...${NC}\n"
direnv_version=$( direnv --version )
if [[ "$direnv_version" =~ 2\.[2-9][0-9]?\.[0-9]? ]]; then
  printf "${GREEN}✓✓✓ direnv already installed!${NC}\n\n\n"
else
  brew install direnv
  direnv_version=$( direnv --version )
  if [[ "$direnv_version" =~ 2\.[2-9][0-9]?\.[0-9]? ]]; then
    printf "${GREEN}✓✓✓ direnv installed!${NC}\n\n\n"
  else
    printf "${RED}Output from version request: %s${NC}\n" "$direnv_version"
    printf "${RED}Unexpected output from direnv installation. Please ask an instructor for help. ${NC}"
    read -p "Proceed? [y/n]: " ans
    if [[ $ans == 'n' ]]; then
      exit 1
    fi
  fi
fi

# atom installation
printf "${BLUE}Installing Atom...${NC}\n"
atom_version=$( atom --version )
if [[ "$atom_version" =~ 1\.[2-9][0-9]?\.[0-9]? ]]; then
  printf "${GREEN}✓✓✓ atom already installed!${NC}\n\n\n"
else
  brew cask install atom
  atom_version=$( atom --version )
  if [[ "$atom_version" =~ 1\.[2-9][0-9]?\.[0-9]? ]]; then
    printf "${GREEN}✓✓✓ atom installed!${NC}\n\n\n"
  else
    printf "${RED}Output from version request: %s${NC}\n" "$atom_version"
    printf "${RED}Unexpected output from atom installation. Please ask an instructor for help. ${NC}"
    read -p "Proceed? [y/n]: " ans
    if [[ $ans == 'n' ]]; then
      exit 1
    fi
  fi
fi

# Setting up virtual environment
printf "${BLUE}Creating virtual environment...${NC}\n"
python3 -m venv env
printf 'PATH_add env/bin' > .envrc
if [ ! -e /Users/`whoami`/.bash_profile ]; then
    printf 'eval "$(direnv hook bash)"' > /Users/`whoami`/.bash_profile
else
    printf '\neval "$(direnv hook bash)"' >> /Users/`whoami`/.bash_profile
fi
source ~/.bash_profile
direnv allow .
python_version=$( python --version )
if [[ "$python_version" =~ "Python "3\.[0-9]\.[0-9]? ]]; then
  printf "${GREEN}✓✓✓ Virtual environment created and auto-activiation configured!${NC}\n\n\n"
else
  printf "${RED}Using: %s, virtual environment auto-activation may not be configured.${NC}\n" "$python_version"
  printf "${RED}Please ask an instructor for help. ${NC}"
  read -p "Proceed? [y/n]: " ans
  if [[ $ans == 'n' ]]; then
    exit 1
  fi
fi

printf "${PURPLE}Your computer is configured! Please restart Terminal. ${NC}\n"
exit 0

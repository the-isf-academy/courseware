#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\e[36m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m'
CLEAR_LINE='\r\033[K'
BOLD='\e[1m'
NORMAL='\e[21m'

function aptupdate() {
	#check for updates
	sudo apt-get update
}

function installpipandpython() {
	#install pip
	sudo apt-get install python-pip
	pip --version
	alias python=python3
	python --version
}

function changeubuntupath() {
	# changes default path of Ubunutu 
	printf "What is your Windows Username? (This is case sensitive):  \n"
	read WINDOWSUSERNAME

	if [[ $WINDOWSUSERNAME = *[[:space:]]* ]]; then
		WINDOWSUSERNAME_NOSPACE=`echo "$WINDOWSUSERNAME" | sed 's/\\ /\\\ /g'` 
	fi	

	DEFAULT_PATH="cd /mnt/c/Users/$WINDOWSUSERNAME_NOSPACE/" 
	printf "\n#changes default Ubunutu path\n$DEFAULT_PATH \n\n" >> ~/.bashrc 
}

function customlscommand() {
	#changes ls command and formatting
	
	TEXT=(
		"#Custom ls command and formatting"
		"LS_COLORS=\$LS_COLORS:'tw=1;44:ow=1;44:di=01;35:ln=90:fi=35:ex=33'"
		"export LS_COLORS" 
		"CUSTOMLS=\"command ls --human-readable --group-directories-first --color=auto -I NTUSER.DAT\* -I ntuser.dat\*\"" 
		"alias ls=\$CUSTOMLS"
	)
	printf '%s\n' "${TEXT[@]}" >> ~/.bashrc 
	source ~/.bashrc



# file system creation
function filesys {
    printf "${CLEAR_LINE}🗂  ${BLUE}Setting up cs9 folder on Desktop...${NC}"
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
    if [[ $SHELL == *"bash" ]];
    then
        FILE=/Users/`whoami`/.bash_profile
        if [ ! -e $FILE ]; then
            printf 'eval "$(direnv hook bash)"' > $FILE
        else
            if ! grep -q 'eval "$(direnv hook bash)"' "$FILE"; then
                cp $FILE ${FILE}_pre_cs9
                printf '\n# Added for ISF cs9 setup.\n# Original bash profile can be found in .bash_profile_pre_cs9\neval "$(direnv hook bash)"' >> $FILE
            fi
        fi
        source ~/.bash_profile
    elif [[ $SHELL == *"zsh" ]];
    then
        FILE=/Users/`whoami`/.zshrc
        if [ ! -e $FILE ]; then
            printf 'eval "$(direnv hook zsh)"' > $FILE
        else
            if ! grep -q 'eval "$(direnv hook zsh)"' "$FILE"; then
                cp $FILE ${FILE}_pre_cs9
                printf '\n# Added for ISF cs9 setup.\n# Original zsh profile can be found in .zshrc_pre_cs9\neval "$(direnv hook zsh)"' >> $FILE
            fi
        fi
		source ~/.zshrc

    else
        printf "Sorry, $SHELL is not supported. Please switch to bash or zsh and try again."
    fi
    direnv allow .
}


INTRO_TEXT=(
	"Running this script will download some new software and get your computer setup up for the class."
	"Some of the steps may take a while to complete."
	"If you get stuck or have any questions, ask a teacher."

)

INTRO_PASSWORD_TEXT=(
	" The setup may ask for your password."
	" As a security measure, you won't see any characters when you type it in."
)
printf "${BLUE}--- Welcome to the CS9 setup script! ---\n"

printf '%s\n' "${INTRO_TEXT[@]}"
printf '\n'
printf "${BLUE}**Note: ${NC}\n"

printf '%s\n' "${INTRO_PASSWORD_TEXT[@]}"
printf '\n'
printf "${BLUE}-- Ready to begin? ${NC}\n"

read -p "(Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
printf '\n-------------------------------\n'

printf "${BLUE}--- Updating...${NC}\n"
#aptupdate

printf "${BLUE}--- Installing pip and Python...${NC}\n"
#installpipandpython

printf "${BLUE}--- Updating bash profile...${NC}\n"
#changeubuntupath
#customlscommand


printf "🗂  ${BLUE}Setting up cs9 folder on Desktop...${NC}"
filesys
setup_venv
printf "${CLEAR_LINE}👍  ${GREEN}cs9 folder created!${NC}\n"

printf "${PURPLE}Your computer is configured! Please restart Terminal. ${NC}\n"
exit 0
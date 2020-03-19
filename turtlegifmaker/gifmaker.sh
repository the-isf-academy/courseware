printf "${BLUE}Installing Magick and Ghostscript...${NC}\n"
brew install magick
brew install ghostscript
magick_version=$( magick --version )

if [[ "$magick_version" =~ "magick version "[2-9][0-9][0-9][0-9]"." ]]; then
  printf "${GREEN}✓✓✓ Magick installed!${NC}\n\n\n"
else
  printf "${RED}Message from version request: %s${NC}\n" "$magick_version"
  printf "${RED}Unexpected output from magick installation. ${NC}"
  read -p "Proceed? [y/n]: " ans
  if [[ $ans == 'n' ]]; then
    exit 1
  fi
fi

magick screenshot*.eps drawing.gif
rm screenshot*.eps

printf "${GREEN}drawing.gif should be created! ${NC}\n"
exit 0

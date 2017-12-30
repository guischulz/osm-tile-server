#!/bin/bash -eux

# Install Noto fonts that are not available as apt package

NOTO_FONT_DIR=/usr/share/fonts/truetype/noto

if [ ! -d ${HOME}/src ]; then
  mkdir ${HOME}/src
fi

# Noto Emoji Regular font
if [ ! -d ${HOME}/src/noto-emoji/fonts ]; then
  mkdir -p ${HOME}/src/noto-emoji/fonts
  cd ${HOME}/src/noto-emoji/fonts
  wget https://github.com/googlei18n/noto-emoji/raw/master/fonts/NotoEmoji-Regular.ttf
  sudo cp ${HOME}/src/noto-emoji/fonts/NotoEmoji-Regular.ttf ${NOTO_FONT_DIR}
fi

# Noto Sans Arabic UI Regular/Bold font
if [ ! -d ${HOME}/src/noto-fonts/hinted ]; then
  mkdir -p ${HOME}/src/noto-fonts/hinted
  cd ${HOME}/src/noto-fonts/hinted
  wget https://github.com/googlei18n/noto-fonts/raw/master/hinted/NotoSansArabicUI-Regular.ttf
  wget https://github.com/googlei18n/noto-fonts/raw/master/hinted/NotoSansArabicUI-Bold.ttf
  sudo cp ${HOME}/src/noto-fonts/hinted/NotoSansArabicUI-Regular.ttf ${NOTO_FONT_DIR}
  sudo cp ${HOME}/src/noto-fonts/hinted/NotoSansArabicUI-Bold.ttf ${NOTO_FONT_DIR}
fi

# rebuild the font cache
sudo fc-cache -fv

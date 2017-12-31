#!/bin/bash -eux

# Install all required software packages

declare -x DEBIAN_FRONTEND="noninteractive"

# build tools
sudo apt-get -yq install build-essential

# git
sudo apt-get -yq install git

# postgresql / postgis
sudo apt-get -yq install postgresql postgresql-contrib postgis postgresql-9.5-postgis-2.2

# osm2pgsql / osmosis
sudo apt-get -yq install osm2pgsql osmosis

# mod-tile / renderd
sudo apt-get -yq install autoconf libtool libmapnik-dev apache2-dev

# carto / mapnik styles
sudo apt-get -yq install npm nodejs-legacy mapnik-utils
sudo npm install --no-progress -g carto

# fonts
sudo apt-get -yq install fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted fonts-hanazono ttf-unifont

# apache
sudo apt-get -yq install apache2

# poly-bounds.py
sudo apt-get -yq install python-shapely

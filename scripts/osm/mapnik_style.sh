#!/bin/bash -eux
# sudo -H -u osm ./mapnik_style.sh

# Stylesheet configuration
#
# The style we'll use here is the one that is used by the "standard" map on
# the openstreetmap.org website.

OSM_CARTO_VERSION=v4.6.0

if [ ! -d ${HOME}/src ]; then
  mkdir ${HOME}/src
fi
cd ${HOME}/src

if [ ! -d ${HOME}/src/openstreetmap-carto ]; then
  git clone git://github.com/gravitystorm/openstreetmap-carto.git
fi
cd ${HOME}/src/openstreetmap-carto

git checkout tags/${OSM_CARTO_VERSION}

scripts/get-shapefiles.py
carto project.mml > mapnik.xml

# remove obsolete font definition that is unknown to Ubuntu
sed -i '/.*Font face-name="unifont Medium".*/d' ${HOME}/src/openstreetmap-carto/mapnik.xml

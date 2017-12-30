#!/bin/bash -eux
# sudo -H -u osm ./import_data.sh

# Download map data and import data to PostgreSQL
#
# Reduce CACHE_SIZE on a server with less than 8 GB memory.

if [ ! -z ${1:-} ]; then
  OSM_DATA_FILE_URL=$1
elif [ -z ${OSM_DATA_FILE_URL+x} ]; then
  OSM_DATA_FILE_URL=http://download.geofabrik.de/europe/germany/nordrhein-westfalen/arnsberg-regbez-latest.osm.pbf
fi

PBF_DATA_FILE=`basename ${OSM_DATA_FILE_URL}`
CACHE_SIZE=2048

if [ ! -d ${HOME}/data ]; then
  mkdir ${HOME}/data
fi
cd ${HOME}/data

# download data file
wget ${OSM_DATA_FILE_URL}

# load data
osm2pgsql -d gis --create --slim  -G --hstore --tag-transform-script ${HOME}/src/openstreetmap-carto/openstreetmap-carto.lua -C ${CACHE_SIZE} --number-processes 1 -S ${HOME}/src/openstreetmap-carto/openstreetmap-carto.style ${HOME}/data/${PBF_DATA_FILE}

# mod_tile requires the date of the last full import
if [ -d /var/lib/mod_tile ]; then
  touch /var/lib/mod_tile/planet-import-complete
fi

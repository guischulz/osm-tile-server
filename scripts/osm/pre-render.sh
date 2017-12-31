#!/bin/bash -eux
# sudo -H -u osm ./pre-render.sh

# Setup script for automatic rendering of tiles
#
# Adjust NUM_THREADS depending on the number of available CPUs.

NUM_THREADS=3
MIN_ZOOM=1
MAX_ZOOM=13

if [ ! -z ${1:-} ]; then
  OSM_EXTENT_FILE_URL=$1
elif [ -z ${OSM_EXTENT_FILE_URL+x} ]; then
  OSM_EXTENT_FILE_URL=http://download.geofabrik.de/europe/germany/nordrhein-westfalen/arnsberg-regbez.poly
fi
OSM_EXTENT_FILE=`basename ${OSM_EXTENT_FILE_URL}`

# download poly file with extent of region
cd ${HOME}/data
wget -O ${OSM_EXTENT_FILE} ${OSM_EXTENT_FILE_URL}

# get perl script to render tiles using geographic coordinates
cd ${HOME}/src
if [ ! -d ${HOME}/src/render_list_geo.pl ]; then
  # use fork of https://github.com/alx77/render_list_geo.pl
  git clone https://github.com/guischulz/render_list_geo.pl.git
fi
cp ${HOME}/src/render_list_geo.pl/render_list_geo.pl ${HOME}/bin
chmod ug+x ${HOME}/bin/render_list_geo.pl

# determine bounds from extent file
BOUNDS_PARAMS=`${HOME}/bin/poly-bounds.py ${HOME}/data/${OSM_EXTENT_FILE}`

# create tile render script
RENDER_SCRIPT=${HOME}/bin/render_tiles.sh
echo -e '#!/bin/bash -eux\n' | tee ${RENDER_SCRIPT}
echo "NUM_THREADS=${NUM_THREADS}" | tee -a ${RENDER_SCRIPT}
echo "MIN_ZOOM=${MIN_ZOOM}" | tee -a ${RENDER_SCRIPT}
echo "MAX_ZOOM=${MAX_ZOOM}" | tee -a ${RENDER_SCRIPT}
echo "BOUNDS_PARAMS='${BOUNDS_PARAMS}'" | tee -a ${RENDER_SCRIPT}
echo "RENDER_LIST_GEO=${HOME}/bin/render_list_geo.pl" | tee -a ${RENDER_SCRIPT}
echo -e '\n${RENDER_LIST_GEO} -f -n ${NUM_THREADS} -m default ${BOUNDS_PARAMS} -z ${MIN_ZOOM} -Z ${MAX_ZOOM}' | tee -a ${RENDER_SCRIPT}
echo -e '\n# remove blank tiles' | tee -a ${RENDER_SCRIPT}
echo 'find /var/lib/mod_tile -name "*.meta" -type f -size 7124c -exec rm {} \;' | tee -a ${RENDER_SCRIPT}
chmod ug+x ${RENDER_SCRIPT}

# run tile render script
 ${RENDER_SCRIPT}

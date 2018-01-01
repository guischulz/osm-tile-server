#!/bin/bash -eu

# Install and configure OSM tile server components:
# PostgreSQL, Mapnik, Apache, mod_tile, carto, openstreetmap-carto, osm2pgsql
#
# Run this script as a user with full sudo privileges without password.
if ! sudo -n true 2>/dev/null; then
    echo "You don't have sudo rights without password"
    echo "Create a file /etc/sudoers.d/${USER} with the following line"
    echo -e "${USER}\tALL=(ALL) NOPASSWD: ALL"
    exit 1
fi
set -x

# system user for rendering and database access
declare -x OSM_ACCOUNT=osm
# osm pbf data file to import
declare -x OSM_DATA_FILE_URL=http://download.geofabrik.de/europe/germany/nordrhein-westfalen/detmold-regbez-latest.osm.pbf
# osm poly file with extent of region
declare -x OSM_EXTENT_FILE_URL=http://download.geofabrik.de/europe/germany/nordrhein-westfalen/detmold-regbez.poly
# osm updates
declare -x OSM_UPDATE_URL=http://download.geofabrik.de/europe/germany/nordrhein-westfalen/detmold-regbez-updates

# create user
./osm/create_user.sh
# install all required packages
./osm/install_packages.sh
# setup database
./osm/create_database.sh

# install additional fonts
./osm/install_fonts.sh
# configure database settings for full import
./osm/postgresql_full.sh

# get mapnik style configuration
sudo -H -u ${OSM_ACCOUNT} ./osm/mapnik_style.sh
# initial full import
sudo -H -u ${OSM_ACCOUNT} ./osm/import_data.sh ${OSM_DATA_FILE_URL} ${OSM_UPDATE_URL}

# configure database settings for normal use
./osm/postgresql_normal.sh

# compile and install mod_tile/renderd
./osm/mod_tile.sh
./osm/apache.sh

# setup osm daily diff updates
./osm/cron_osmupdate.sh ${OSM_UPDATE_URL}
# create and run pre-render script
sudo -H -u ${OSM_ACCOUNT} ./osm/pre-render.sh ${OSM_EXTENT_FILE_URL}

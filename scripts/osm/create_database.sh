#!/bin/bash -eux

# Create PostgreSQL database

if [ -z ${OSM_ACCOUNT+x} ]; then
  DB_USER=osm
else
  DB_USER=${OSM_ACCOUNT}
fi

sudo -u postgres createuser ${DB_USER}
sudo -u postgres createdb -E UTF8 -O ${DB_USER} gis
sudo -u postgres psql -c "CREATE EXTENSION hstore;" -d gis
sudo -u postgres psql -c "CREATE EXTENSION postgis;" -d gis
sudo -u postgres psql -c "ALTER TABLE geometry_columns OWNER TO ${DB_USER};" -d gis
sudo -u postgres psql -c "ALTER TABLE spatial_ref_sys OWNER TO ${DB_USER};" -d gis

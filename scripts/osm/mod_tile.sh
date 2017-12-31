#!/bin/bash -eux

# Install mod_tile and renderd
#
# "mod_tile" is an Apache module that handles requests for tiles; "renderd" is
# a daemon that actually renders tiles when "mod_tile" requests them. We'll
# use https://github.com/SomeoneElseOSM/mod_tile, which is itself forked from
# https://github.com/openstreetmap/mod_tile, but modified so that it supports
# Ubuntu 16.04, and with a couple of other changes to work on a standard
# Ubuntu server rather than one of OSM's rendering servers.
#
# Adjust NUM_THREADS depending on the number of available CPUs.

if [ -z ${OSM_ACCOUNT+x} ]; then
  OSM_ACCOUNT=osm
fi
NUM_THREADS=3

# get mod_tile source code
if [ ! -d ${HOME}/src ]; then
  mkdir ${HOME}/src
fi
cd ${HOME}/src
if [ ! -d ${HOME}/src/mod_tile ]; then
  git clone git://github.com/SomeoneElseOSM/mod_tile.git
fi
cd ${HOME}/src/mod_tile

# compile mod_tile source code
./autogen.sh
./configure
make
sudo make install
sudo make install-mod_tile
sudo ldconfig

# create required renderd directories
if [ ! -d /var/lib/mod_tile ]; then
  sudo mkdir /var/lib/mod_tile
fi

sudo chown ${OSM_ACCOUNT} /var/lib/mod_tile
if [ ! -d /var/run/renderd ]; then
  sudo mkdir /var/run/renderd
fi
sudo chown ${OSM_ACCOUNT} /var/run/renderd

# mod_tile requires the date of the last full import
if [ ! -f /var/lib/mod_tile/planet-import-complete ]; then
  sudo -u ${OSM_ACCOUNT} touch /var/lib/mod_tile/planet-import-complete
fi

# adjust renderd configuration
sudo sed -i -e "s/^num_threads=[0-9]*/num_threads=${NUM_THREADS}/" \
            -e 's/^\[ajt\]$/\[default\]/' \
            -e 's/^URI=.*/URI=\/osm_tiles\//' \
            -e "s/^XML=\/home\/renderaccount\//XML=\/home\/${OSM_ACCOUNT}\//" /usr/local/etc/renderd.conf

# create systemd service
sed -e "s/^RUNASUSER=.*/RUNASUSER=${OSM_ACCOUNT}/" \
    ${HOME}/src/mod_tile/debian/renderd.init | sudo tee /etc/init.d/renderd    
sudo chmod u+x /etc/init.d/renderd
sudo cp ${HOME}/src/mod_tile/debian/renderd.service /lib/systemd/system/

# enable and start service
sudo systemctl enable renderd
sudo systemctl start renderd

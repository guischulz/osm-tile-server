#!/bin/bash -eux

# Setting up Apache2 web server
#
# This script will add a apache site only for localhost.
#
# You propably want to configure ServerName, ServerAdmin, DocumentRoot and
# the VirtualHost address/port afterwards.

# enable mod_tile module
echo 'LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so' | sudo tee /etc/apache2/mods-available/tile.load
sudo a2enmod tile

# create and enable a demo site for localhost
# (site can only be accessed by http://localhost)
sudo cp ${PWD}/../conf/osm/apache_vhost_mod_tile.conf /etc/apache2/sites-available/osm-tile-server.conf
sudo a2ensite osm-tile-server

# create www home with simple openlayer and leaflet client
if [ ! -d /var/www/vhosts/localhost ]; then
  sudo mkdir -p /var/www/vhosts/localhost
fi
sudo cp ${PWD}/../www/openlayers.html /var/www/vhosts/localhost/
sudo cp ${PWD}/../www/leaflet.html /var/www/vhosts/localhost/

# restart service
sudo systemctl restart apache2

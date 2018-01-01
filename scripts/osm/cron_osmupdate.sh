#!/bin/bash -eux

# Configure OSM update scripts

if [ -z ${OSM_ACCOUNT+x} ]; then
  OSM_ACCOUNT=osm
fi
if [ ! -z ${1:-} ]; then
  OSM_UPDATE_URL=$1
elif [ -z ${OSM_UPDATE_URL+x} ]; then
  OSM_UPDATE_URL=http://download.geofabrik.de/europe/germany/nordrhein-westfalen/arnsberg-regbez-updates
fi

# make log directory
if [ ! -d /var/log/tiles ]; then
 sudo mkdir /var/log/tiles
fi
sudo chgrp ${OSM_ACCOUNT} /var/log/tiles
sudo chmod g+w /var/log/tiles

# copy required scripts
if [ ! -d /home/${OSM_ACCOUNT}/bin ]; then
  sudo -u ${OSM_ACCOUNT} mkdir /home/${OSM_ACCOUNT}/bin
  sudo cp ${HOME}/src/mod_tile/openstreetmap-tiles-update-expire /home/${OSM_ACCOUNT}/bin
  sudo cp ${HOME}/src/mod_tile/osmosis-db_replag /home/${OSM_ACCOUNT}/bin
  sudo cp ../src/poly-bounds.py /home/${OSM_ACCOUNT}/bin
  sudo chmod ug+x /home/${OSM_ACCOUNT}/bin/openstreetmap-tiles-update-expire
  sudo chmod ug+x /home/${OSM_ACCOUNT}/bin/osmosis-db_replag
  sudo chmod ug+x /home/${OSM_ACCOUNT}/bin/poly-bounds.py
  sudo chown -R ${OSM_ACCOUNT}:${OSM_ACCOUNT} /home/${OSM_ACCOUNT}/bin
fi

# configure update script (update path and style sheet; disable filtering diff)
sed -e "s#^cd /.*/mod_tile/#cd /home/${OSM_ACCOUNT}/bin/#" \
    -e 's/ --map=ajt / --map=default /' \
    -e 's/m_ok "filtering diff"/#m_ok "filtering diff"/' \
    -e 's/^\(if ! \/home\/renderaccount.*trim_osc.py.*then\)/if ! :; then #\1/g' \
    ${HOME}/src/mod_tile/openstreetmap-tiles-update-expire | sudo -u ${OSM_ACCOUNT} tee /home/${OSM_ACCOUNT}/bin/openstreetmap-tiles-update-expire

# initialization (created state file will be wrong!)
if [ ! -d /var/lib/mod_tile/.osmosis ]; then
  sudo -H -u ${OSM_ACCOUNT} /home/${OSM_ACCOUNT}/bin/openstreetmap-tiles-update-expire 2017-01-01T00:00:00Z
fi

# update configuration (set base url for updates)
sudo -u ${OSM_ACCOUNT} sed -i -e "s#^baseUrl=.*#baseUrl=${OSM_UPDATE_URL}#" \
                   -e 's/^maxInterval =.*/maxInterval = 0/' \
                   /var/lib/mod_tile/.osmosis/configuration.txt

# replace state with correct version from initial import; should have been created by import_data.sh
if [ -f /home/${OSM_ACCOUNT}/data/initial_state.txt ]; then
  cat /home/${OSM_ACCOUNT}/data/initial_state.txt | sudo -u ${OSM_ACCOUNT} tee /var/lib/mod_tile/.osmosis/state.txt
else
  wget -O - ${OSM_UPDATE_URL}/state.txt | sudo -u ${OSM_ACCOUNT} tee /var/lib/mod_tile/.osmosis/state.txt
fi

# create cron job for daily update (will run everyday at 3:30)
echo -e "30 3 * * * ${OSM_ACCOUNT} /home/${OSM_ACCOUNT}/bin/openstreetmap-tiles-update-expire >/dev/null 2>&1" | sudo tee /etc/cron.d/osmupdate

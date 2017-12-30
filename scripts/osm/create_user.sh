#!/bin/bash -eux

# Create system user for rendering

if [ -z ${OSM_ACCOUNT+x} ]; then
  OSM_ACCOUNT=osm
fi

if id ${OSM_ACCOUNT} >/dev/null 2>&1; then
  echo "Using existing user '${OSM_ACCOUNT}'"
else
  echo "Creating new user '${OSM_ACCOUNT}'"
  sudo adduser --disabled-password --disabled-login --gecos "" ${OSM_ACCOUNT}
fi

osm-tile-server
===============
Installing an OpenStreetMap tile server on Ubuntu 16.04 server

Usage
-----

Login with a user that has full sudo privileges without requiring a password. If your user requires a password for sudo access (run `sudo -n true` to test it), you can create a file `/etc/sudoers.d/username` with the following content (replace *username* with your actual user name)

    username  ALL=(ALL) NOPASSWD: ALL

Clone the repository:

    git clone https://github.com/guischulz/osm-tile-server

Change working directory to the `scripts` sub-directory:

    cd osm-tile-server/scripts

Configure setup script and modify `OSM_DATA_FILE_URL`,  `OSM_EXTENT_FILE_URL` and `OSM_UPDATE_URL` environment variables:

    nano setup_osm.sh

Run setup script:

    ./setup_osm.sh

The script will
- install all required packages for PostgreSQL, Mapnik, Apache, [mod_tile](https://github.com/SomeoneElseOSM/mod_tile), carto, [openstreetmap-carto](https://github.com/gravitystorm/openstreetmap-carto), osm2pgsql, osmosis
- create a system user `osm` for database access and rendering
- create a PostgreSQL database `gis` and import the osm data
- get the Mapnik style configuration used by http://www.openstreetmap.org
- compile and install the Apache module `mod_tile` and the OSM render daemon `renderd`
- setup a daily cron job to update the OSM data with `osmosis`
- pre-render all tiles in the region from zoom level 1 to level 13
- setup an Apache Virtual Host for http://localhost with simple OpenLayers and Leaflet example clients to access the local OSM tile server


Example
-------
To setup an OpenStreetMap server for Germany modify the environment variables in `setup_osm.sh` as follows

    declare -x OSM_DATA_FILE_URL=http://download.geofabrik.de/europe/germany-latest.osm.pbf
    declare -x OSM_EXTENT_FILE_URL=http://download.geofabrik.de/europe/germany.poly
    declare -x OSM_UPDATE_URL=http://download.geofabrik.de/europe/germany-updates

You need about 140 GB free space during the import process. The scripts are currently optimised for a hardware setup with 4 CPUs and 8 GB memory and are tested against a newly installed Ubuntu 16.04 server OS running in VirtualBox.  
You can easily create a working VirtualBox image with a pre-configured packer template from https://github.com/guischulz/packer-templates. You only need to adjust the disk size to 140000.

    packer build -only=virtualbox-iso -var disk_size=140000  ubuntu-16.04.03-server-amd64.json

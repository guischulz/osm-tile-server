#!/bin/bash -eux

# Re-enable PostgreSQL autovacuum and fsync

sudo sed -i -e 's/^autovacuum = off/#autovacuum = on/' \
            -e 's/^fsync = off/#fsync = on/' /etc/postgresql/9.5/main/postgresql.conf

sudo /etc/init.d/postgresql reload

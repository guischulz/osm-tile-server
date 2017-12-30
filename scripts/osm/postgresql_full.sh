#!/bin/bash -eux

# Tune PostgreSQL for better performance
#
# Reduce shared_buffers, maintenance_work_mem and work_mem on a server with less than 8 GB memory.
# Warning: autovacuum and fsync should be re-enabled after initial import

sed -e "s/^#work_mem = [0-9]*MB/work_mem = 64MB/" \
    -e "s/^#maintenance_work_mem = [0-9]*MB/maintenance_work_mem = 128MB/" \
    -e 's/^#autovacuum = on/autovacuum = off/' \
    -e "s/^shared_buffers = [0-9]*MB/shared_buffers = 256MB/" \
    -e "s/^#checkpoint_timeout = [0-9]*min/checkpoint_timeout = 30min/" \
    -e "s/^#checkpoint_completion_target = 0\.[0-9]*/checkpoint_completion_target = 0.9/" \
    -e "s/^#full_page_writes = on/full_page_writes = off/" \
    -e "s/^#fsync = on/fsync = off/" \
    /etc/postgresql/9.5/main/postgresql.conf | sudo tee /etc/postgresql/9.5/main/postgresql.conf
    
sudo /etc/init.d/postgresql reload
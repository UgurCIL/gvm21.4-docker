#!/bin/bash

# Start redis-server
echo "Starting redis-server"
sudo -u redis redis-server --unixsocket /run/redis-openvas/redis.sock --unixsocketperm 770 \
                           --timeout 0 --maxclients 4096 --daemonize yes --port 6379 --bind 127.0.0.1 \
                           --loglevel DEBUG --logfile /var/log/redis/redis-server.log

echo "Wait for redis socket to be created..."
while [ ! -S /run/redis-openvas/redis.sock ]; do
	sleep 1
done

echo "Testing redis-server..."
PONG="$(redis-cli -s /run/redis-openvas/redis.sock ping)"
while [ "${PONG}" != "PONG" ]; do
	echo "Redis-server not ready..."
	sleep 1
	PONG="$(redis-cli -s /run/redis-openvas/redis.sock ping)"
done
echo "Redis-server ready."

# PostgreSQL setup and start
echo "Starting Postgres"
service postgresql start

PGSQL="$(service postgresql status | awk '{print$4}')"
while [ "${PGSQL}" != "online" ]; do
	sleep 1
done
echo "Postgres ready."

# Creating GVM database
echo "Creating GVM database"
sudo -u postgres createuser -DRS gvm
sudo -u postgres createdb -O gvm gvmd
sudo -u postgres psql --dbname=gvmd --command='create role dba with superuser noinherit;'
sudo -u postgres psql --dbname=gvmd --command='grant dba to gvm;'
sudo -u postgres psql --dbname=gvmd --command='create extension "uuid-ossp";'
sudo -u postgres psql --dbname=gvmd --command='create extension "pgcrypto";'

# Dynamic Loader Cache
ldconfig

# Create GVM admin user
gvmd --create-user=admin --password=admin
ADMIN_UUID=$(sudo gvmd --get-users --verbose | awk '{print $2}')
if [ -z "${ADMIN_UUID}" ]
then
	echo "No GVM admin user, check it manually"
	exit
else
	gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value $ADMIN_UUID
fi

# Generate GVM HTTPS certs
sudo -u gvm /usr/local/bin/gvm-manage-certs -a

sudo -u gvm greenbone-nvt-sync && \
sudo -u gvm greenbone-feed-sync --type SCAP && \
sudo -u gvm greenbone-feed-sync --type CERT && \
sudo -u gvm greenbone-feed-sync --type GVMD_DATA

# Start ospd-openvas
sudo -u gvm ospd-openvas --log-file /var/log/gvm/ospd-openvas.log --unix-socket=/run/ospd/ospd.sock --pid-file=/run/ospd/ospd-openvas.pid --log-level DEBUG --socket-mode=0o770
while [ ! -S /run/ospd/ospd.sock ]; do
	sleep 1
done

# Start gvmd
sudo -u gvm gvmd --osp-vt-update=/run/ospd/ospd.sock --listen-group=gvm

# Start gsad
sudo -u gvm gsad --listen=0.0.0.0 --port=9392 --http-only --no-redirect

# Keep container runnig
exec /bin/bash;
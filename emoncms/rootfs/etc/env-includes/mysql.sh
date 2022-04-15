#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

if bashio::services.available 'mysql'; then
    export MYSQL_DATABASE=emoncms
    export MYSQL_HOST
    MYSQL_HOST=$(bashio::services mysql "host")
    export MYSQL_USER
    MYSQL_USER=$(bashio::services mysql "username")
    export MYSQL_PASSWORD
    MYSQL_PASSWORD=$(bashio::services mysql "password")
    export MYSQL_PORT
    MYSQL_PORT=$(bashio::services mysql "port")
fi

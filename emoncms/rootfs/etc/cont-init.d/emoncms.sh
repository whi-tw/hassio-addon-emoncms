#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Community Add-on: EmonCms
# Configures EmonCms
# ==============================================================================

set -euo pipefail

# shellcheck source=../env-includes/mysql.sh
source /etc/env-includes/mysql.sh
# shellcheck source=../env-includes/mqtt.sh
source /etc/env-includes/mqtt.sh
# shellcheck source=../env-includes/etc.sh
source /etc/env-includes/etc.sh

if ! bashio::services.available 'mysql'; then
    bashio::log.fatal \
    "Local database access should be provided by the MariaDB addon"
    bashio::exit.nok \
    "Please ensure it is installed and started"
else
    bashio::log.warning "Emoncms is using the Maria DB addon"
    bashio::log.warning "Please ensure this is included in your backups"
    bashio::log.warning "Uninstalling the MariaDB addon will remove any data"
fi

if bashio::services.available 'mqtt'; then
    bashio::log.warning "Emoncms is using the Mosquitto addon"
    bashio::log.warning "Please ensure this is included in your backups"
else
    export MQTT_ENABLED=false
    export MQTT_HOST=
    export MQTT_USER=
    export MQTT_PASSWORD=
    export MQTT_BASETOPIC=
fi

bashio::log.info "Creating database for Emoncms if required"

mysql \
    -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
    -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" \
    -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` ;"


cd /var/www/emoncms || exit 1


# Configure logging

bashio::log.info "Setting up logging"

mkdir -p ${LOG_DIR}
touch ${LOG_FILE}
chmod 666 ${LOG_FILE}

# Configure persistant storage

bashio::log.info "Setting up persistant storage"

# Ensure persistant storage exists
if ! bashio::fs.directory_exists "${DATA_DIR}"; then
    bashio::log.debug 'Data directory not initialized, doing that now...'

    # Create directories
    mkdir -p ${PHPFINA_DIR}
    mkdir -p ${PHPTIMESERIES_DIR}

    # Ensure file permissions
    chown -R nginx:nginx ${DATA_DIR}
    find ${DATA_DIR} -not -perm 0644 -type f -exec chmod 0644 {} \;
    find ${DATA_DIR} -not -perm 0755 -type d -exec chmod 0755 {} \;
fi

# Run migrations

bashio::log.info "Running migrations if needed"

php scripts/emoncms-cli admin:dbupdate

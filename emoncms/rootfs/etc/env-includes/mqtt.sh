#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

if bashio::services.available 'mqtt'; then
    export MQTT_ENABLED=true
    export MQTT_HOST
    MQTT_HOST=$(bashio::services mqtt "host")
    export MQTT_USER
    MQTT_USER=$(bashio::services mqtt "username")
    export MQTT_PASSWORD
    MQTT_PASSWORD=$(bashio::services mqtt "password")
    export MQTT_BASETOPIC
    MQTT_BASETOPIC=$(bashio::config "mqtt_basetopic" "emon")
fi

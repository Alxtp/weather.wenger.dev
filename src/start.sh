#!/bin/sh

echo "WEEWX_HOME: ${WEEWX_HOME}"

echo 'Starting weewx'

. "${WEEWX_HOME}"/weewx-venv/bin/activate
weewxd --loop-on-init --config "${WEEWX_HOME}/weewx.conf"

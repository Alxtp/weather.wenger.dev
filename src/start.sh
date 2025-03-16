#!/bin/bash

echo "WEEWX_HOME: ${WEEWX_HOME}"

# start weewx
echo 'Starting weewx'

# shellcheck source=/dev/null
. "${WEEWX_HOME}"/weewx-venv/bin/activate
weewxd --loop-on-init --config "${WEEWX_HOME}/weewx.conf"

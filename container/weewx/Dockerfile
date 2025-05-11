ARG PYTHON_VERSION="3.13"
ARG WEEWX_HOME="/home/weewx"

FROM python:${PYTHON_VERSION} AS build

ARG WEEWX_VERSION="5.1.0"
ARG WDC_VERSION="v3.5.1"
ARG WEEWX_HOME

ARG LANGUAGE
ARG STATION_ALTITUDE
ARG STATION_LATITUDE
ARG STATION_LONGITUDE
ARG STATION_LOCATION
ARG MQTT_ENABLED
ARG MQTT_HOST
ARG MQTT_PORT
ARG MQTT_SSL

RUN python -m pip install --upgrade pip
RUN pip install --upgrade virtualenv

WORKDIR /tmp

RUN wget -nv -O "weewx-wdc-${WDC_VERSION}.zip" "https://github.com/Daveiano/weewx-wdc/releases/download/${WDC_VERSION}/weewx-wdc-${WDC_VERSION}.zip" &&\
    wget -nv -O "weewx-mqtt.zip" "https://github.com/matthewwall/weewx-mqtt/archive/master.zip"

RUN mkdir /tmp/weewx-wdc/ &&\
    unzip /tmp/weewx-wdc-${WDC_VERSION}.zip -d /tmp/weewx-wdc/

WORKDIR ${WEEWX_HOME}

RUN python -m venv ${WEEWX_HOME}/weewx-venv &&\
    . ${WEEWX_HOME}/weewx-venv/bin/activate &&\
    python -m pip install --no-cache-dir paho-mqtt==1.6.1 weewx==${WEEWX_VERSION}

RUN . ${WEEWX_HOME}/weewx-venv/bin/activate &&\
    weectl station create "${WEEWX_HOME}" --no-prompt \
    --driver=weewx.drivers.vantage \
    --altitude="${STATION_ALTITUDE}" \
    --latitude=${STATION_LATITUDE} \
    --longitude=${STATION_LONGITUDE} \
    --location="${STATION_LOCATION}" \
    --units="metricwx"

# enable console logging
RUN echo '[Logging]\n    [[root]]\n      level = INFO\n      handlers = console,' >> weewx.conf

RUN . ${WEEWX_HOME}/weewx-venv/bin/activate &&\
    weectl extension install -y --config "${WEEWX_HOME}/weewx.conf" /tmp/weewx-wdc/ &&\
    weectl extension install -y --config "${WEEWX_HOME}/weewx.conf" /tmp/weewx-mqtt.zip

COPY src/skin.conf src/favicon.ico ./skins/weewx-wdc/

RUN --mount=type=secret,id=mqtt_password \
    MQTT_PASSWORD=$(cat /run/secrets/mqtt_password) &&\
    sed -i -z -e "s/debug = 0/debug = 1/" weewx.conf &&\
    sed -i -z -e "s/skin = Seasons\n        enable = true/skin = Seasons\n        enable = false/" weewx.conf &&\
    sed -i -z -e "s/lang = en/lang = ${LANGUAGE}/" weewx.conf &&\
    sed -i -z -e "s/\[\[\[\[Groups\]\]\]\]/[[[[Groups]]]]\n                group_speed = km_per_hour\n                group_speed2 = km_per_hour2/" weewx.conf &&\
    sed -i -z -e "s|INSERT_SERVER_URL_HERE|mqtt://weewx:${MQTT_PASSWORD}@weewx-mosquitto:1883\n        topic = weather\n        unit_system = METRICWX\n        binding = loop\n        [[[inputs]]]\n            [[[[windSpeed]]]]\n                format = %.0f\n            [[[[windGust]]]]\n                format = %.0f|g" weewx.conf &&\
    sed -i -z -e "s/mqtt_websockets_enabled = 0/mqtt_websockets_enabled = ${MQTT_ENABLED}/" ./skins/weewx-wdc/skin.conf &&\
    sed -i -z -e "s/mqtt_websockets_host = [\"][\"]/mqtt_websockets_host = \"${MQTT_HOST}\"/" ./skins/weewx-wdc/skin.conf &&\
    sed -i -z -e "s/mqtt_websockets_port = 80/mqtt_websockets_port = ${MQTT_PORT}/" ./skins/weewx-wdc/skin.conf &&\
    sed -i -z -e "s/mqtt_websockets_ssl = 0/mqtt_websockets_ssl = ${MQTT_SSL}/" ./skins/weewx-wdc/skin.conf &&\
    sed -i -z -e "s/mqtt_websockets_password = [\"][\"]/mqtt_websockets_password = \"${MQTT_PASSWORD}\"/" ./skins/weewx-wdc/skin.conf

FROM python:${PYTHON_VERSION}-alpine AS final

ARG WEEWX_HOME
ENV WEEWX_HOME=${WEEWX_HOME}
ARG WEEWX_UID=10000
ARG TIMEZONE

COPY --chmod=0755 src/start.sh /start.sh
COPY --from=build ${WEEWX_HOME} ${WEEWX_HOME}

# Configure timezone
RUN ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Create directories and placeholder to keep non-root permission on volumes
RUN mkdir ${WEEWX_HOME}/public_html &&\
    mkdir ${WEEWX_HOME}/archive &&\
    touch ${WEEWX_HOME}/public_html/placeholder

RUN addgroup --system --gid ${WEEWX_UID} weewx &&\
    adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx &&\
    chown -R weewx:weewx ${WEEWX_HOME}

VOLUME [ "${WEEWX_HOME}/public_html" ]
VOLUME [ "${WEEWX_HOME}/archive" ]

USER weewx

ENTRYPOINT [ "/start.sh" ]

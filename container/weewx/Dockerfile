ARG PYTHON_VERSION="3.13"
ARG WEEWX_HOME="/home/weewx"

FROM python:${PYTHON_VERSION} AS build

ARG WEEWX_VERSION="5.1.0"
ARG WDC_VERSION="v3.5.1"
ARG WEEWX_HOME

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
    --altitude="874,meter" \
    --latitude=46.769 \
    --longitude=7.661 \
    --location="Schwendibach, BE" \
    --units="metricwx"

# enable console logging
RUN echo '[Logging]\n    [[root]]\n      level = INFO\n      handlers = console,' >> weewx.conf

RUN . ${WEEWX_HOME}/weewx-venv/bin/activate &&\
    weectl extension install -y --config "${WEEWX_HOME}/weewx.conf" /tmp/weewx-wdc/ &&\
    weectl extension install -y --config "${WEEWX_HOME}/weewx.conf" /tmp/weewx-mqtt.zip

COPY src/skin.conf ./skins/weewx-wdc/

RUN --mount=type=secret,id=mqtt_password \
    MQTT_PASSWORD=$(cat /run/secrets/mqtt_password) &&\
    sed -i -z -e "s/skin = Seasons\n        enable = true/skin = Seasons\n        enable = false/" weewx.conf &&\
    sed -i -z -e "s/lang = en/lang = de_CH.utf8/" weewx.conf &&\
    sed -i -z -e "s/\[\[\[\[Groups\]\]\]\]/[[[[Groups]]]]\n                group_speed = km_per_hour\n                group_speed2 = km_per_hour2/" weewx.conf &&\
    sed -i -z -e "s|INSERT_SERVER_URL_HERE|mqtt://weewx:${MQTT_PASSWORD}@weewx-mosquitto:1883\n        topic = weather\n        unit_system = METRICWX\n        binding = loop\n        [[[inputs]]]\n            [[[[windSpeed]]]]\n                format = %.0f\n            [[[[windGust]]]]\n                format = %.0f|g" weewx.conf &&\
    sed -i -z -e "s/mqtt_websockets_password = [\"][\"]/mqtt_websockets_password = \"${MQTT_PASSWORD}\"/" ./skins/weewx-wdc/skin.conf

FROM python:${PYTHON_VERSION}-alpine AS final

ARG WEEWX_HOME
ENV WEEWX_HOME=${WEEWX_HOME}
ARG WEEWX_UID=10000

COPY --chmod=0755 src/start.sh /start.sh
COPY --from=build ${WEEWX_HOME} ${WEEWX_HOME}

# Configure timezone
RUN ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

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

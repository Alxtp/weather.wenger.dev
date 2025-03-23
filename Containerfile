FROM python:3.13-bookworm

ARG WEEWX_VERSION="5.1.0"
ARG WDC_VERSION="v3.5.1"
ARG WEEWX_UID=2749
ENV WEEWX_HOME="/home/weewx-data"

COPY --chmod=0755 src/start.sh /start.sh

# @see https://blog.nuvotex.de/running-syslog-in-a-container/
# @todo https://www.weewx.com/docs/5.0/usersguide/monitoring/#logging-on-macos

RUN python -m pip install --upgrade pip
RUN pip install --upgrade virtualenv

RUN addgroup --system --gid ${WEEWX_UID} weewx &&\
    adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx

# Configure timezone.
RUN ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

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

# enable weewx-wdc
RUN sed -i -z -e 's/skin = Seasons\n        enable = true/skin = Seasons\n        enable = false/' weewx.conf

# set language
RUN sed -i -z -e 's/lang = en/lang = de_CH.utf8/' weewx.conf

# set custom groups
RUN sed -i -z -e 's/\[\[\[\[Groups\]\]\]\]/[[[[Groups]]]]\n                group_speed = km_per_hour\n                group_speed2 = km_per_hour2/' weewx.conf

# configure weewx-mqtt
RUN sed -i -z -e 's|INSERT_SERVER_URL_HERE|mqtt://user:password@host:port\n        topic = weather\n        unit_system = METRICWX\n        binding = loop\n        [[[inputs]]]\n            [[[[windSpeed]]]]\n                format = %.0f\n            [[[[windGust]]]]\n                format = %.0f|g' weewx.conf

VOLUME [ "${WEEWX_HOME}/public_html" ]
VOLUME [ "${WEEWX_HOME}/archive" ]

ENTRYPOINT [ "/start.sh" ]

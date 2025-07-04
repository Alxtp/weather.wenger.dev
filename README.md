# Weather Station Dashboard

My personal, selfhosted Docker Compose setup for running WeeWX weather station software with the weewx-wdc skin, MQTT broker for live updates, and a web server.

## Overview
This project provides a custom, containerized implementation of WeeWX weather station software with the weewx-wdc skin and MQTT integration with Mosquitto. The setup includes three containers:
- **weewx**: Core weather station software processing data from the private weather station
- **nginx**: Web server to publish the static html files
- **mosquitto**: MQTT broker for live updates on the dashboard

In addition it uses [Traefik](https://traefik.io/traefik) as a reverse proxy and [Cloudflare](https://www.cloudflare.com/) as additional proxy and WAF.

## Sources
- [WeeWX](https://github.com/weewx/weewx) - Weather station software
- [weewx-wdc](https://github.com/Daveiano/weewx-wdc) - Skin for WeeWX
- [weewx-wdc-interceptor-docker](https://github.com/Daveiano/weewx-wdc-interceptor-docker/tree/weewx-mqtt) - Docker implementation with weewx-wdc and MQTT
- [weewx-mqtt](https://github.com/matthewwall/weewx-mqtt) - MQTT extension for WeeWX

# Weewx Docker Compose
Custom WeeWX Docker image with weewx-wdc skin and MQTT support.

## Overview
This project provides a containerized implementation of WeeWX weather station software with the weewx-wdc skin and MQTT integration with Mosquitto. The setup includes three containers:
- **weewx**: Core weather station software processing data from your station
- **nginx**: Web server to display the weewx-wdc weather dashboard
- **mosquitto**: MQTT broker for live updates on the dasboard

## Sources
- [WeeWX](https://github.com/weewx/weewx) - Weather station software
- [weewx-wdc](https://github.com/Daveiano/weewx-wdc) - Skin for WeeWX
- [weewx-wdc-interceptor-docker](https://github.com/Daveiano/weewx-wdc-interceptor-docker/tree/weewx-mqtt) - Docker implementation with weewx-wdc and MQTT
- [weewx-mqtt](https://github.com/matthewwall/weewx-mqtt) - MQTT extension for WeeWX

## Setup
1. Clone the repository:
    ```bash
    git clone https://github.com/GreedTP/weewx
    cd weewx
    ```

2. Create and configure the `.env` file:
    ```bash
    cp .env.example .env
    # Edit .env with your weather station and MQTT configuration
    ```

3. Configure the MQTT password with one of these options:

   - Add to your `.env` file
      ```
      MQTT_PASSWORD="your_secure_password"
      ```

   - Or export as environment variable:
      ```bash
      export MQTT_PASSWORD='your_secure_password'
      ```

4. Modify the `docker-compose.yml` file with the correct usb path of the connected weather statio. Usually:
    ```yaml
    devices:
      - /dev/ttyUSB0:/dev/ttyUSB0
    ```
4. Create a Docker Network which will contain all the services:
    ```bash
    docker network create -d bridge private
    ```

5. Start the Docker Compose stack:
    ```bash
    docker compose up -d
    ```

## Configuration
The weather station and MQTT settings are configured through the `.env` file. See the `.env.example` file for all available options and their descriptions.

## Station Support
The default configuration is set up for a Davis Vantage weather station connected via USB and with the `metricwx` option for units, but you can modify the configuration to work with other supported weather station hardware and units.

## Publish the Dashboard
This setup uses an external Docker network named `private` for all container communications. That means:
- No ports are exposed directly to the host
- Services are only accessible from within the private network
- To access the Website and MQTT externally, setup and configure a reverse proxy to forward requests to the `weewx-nginx` container on port `80` and MQTT websocket connections to the `weewx-mosquitto` container on port `9001`

## Data Persistence
Weather data and configurations are stored in Docker volumes for persistence:
- `db`: Contains the WeeWX SQLite database with archived weather data (database can be replaced with a database of an existing setup to migrate the data)
- `html`: Contains the generated website files
- `mqtt-data` and `mqtt-log`: Store MQTT broker data and logs

# weewx
Custom WeeWX Docker image with weewxwdc skin and MQTT support.

## Setup

1. Clone the repository:
    ```bash
    git clone https://github.com/GreedTP/weewx
    cd weewx
    ```
2. Export environment variable for the mqtt password
    ```bash
    export MQTT_PASSWORD='password'
    ```
3. Create a Network which will contain all the services:
    ```bash
    docker network create -d bridge private
    ```
4. Start the Docker Compose stack:
    ```bash
    docker compose up -d
    ```

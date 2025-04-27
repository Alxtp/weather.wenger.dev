# weewx
Custom WeeWX Docker image

## Setup
When using Podman install QEMU to build for other Platforms: `sudo apt install qemu-user-static`

1. Clone the repository:
    ```bash
    git clone https://github.com/GreedTP/weewx
    cd weewx
    ```
2. Run the `init.sh` script to create a random password file or create a `mqtt_password` file with a password manualy:
    ```bash
    $ ./init.sh
    Generating MQTT password...
    ```
3. Start the Docker Compose stack:
    ```bash
    docker compose up -d
    ```

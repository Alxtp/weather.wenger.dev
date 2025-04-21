# weewx
Custom WeeWX Docker image

# Setup
Install QEMU to build for other Platforms: `sudo apt install qemu-user-static`

Export pwd for mqtt: `export MQTT_PASSWORD=<password>`
Build weewx from source: `podman build -t <tag> --secret id=mqtt_password,env=MQTT_PASSWORD --platform linux/arm64 container/weewx/`
Build mosquitto from source: `podman build -t <tag> --secret id=mqtt_password,env=MQTT_PASSWORD --platform linux/arm64 container/mosquitto/`

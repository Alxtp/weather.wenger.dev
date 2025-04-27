#!/bin/bash

# Create the secret file if it doesn't exist
if [ ! -f ./mqtt_password ]; then
  echo "Generating MQTT password..."
  openssl rand -base64 16 > ./mqtt_password
  chmod 600 ./mqtt_password  # Restrict file permissions
fi

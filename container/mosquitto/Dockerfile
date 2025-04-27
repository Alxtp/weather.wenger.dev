FROM eclipse-mosquitto:2.0

COPY src/mosquitto.conf /mosquitto/config/mosquitto.conf

RUN --mount=type=secret,id=mqtt_password \
    mosquitto_passwd -c -b /mosquitto/config/password_file weewx "${MQTT_PASSWORD}"

RUN chown -R mosquitto:mosquitto /mosquitto

EXPOSE 1883
EXPOSE 9001

USER mosquitto

ENTRYPOINT ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]

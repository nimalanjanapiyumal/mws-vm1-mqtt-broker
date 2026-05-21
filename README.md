# VM1 - MWS MQTT Broker Repository

This repository configures VM1 as the Mosquitto MQTT broker for the Metronia Water Services IoT monitoring subsystem.

## VM details

- Hostname: `mws-mqtt-broker`
- Static IP: `192.168.1.71/24`
- Gateway: `192.168.1.1`
- MQTT port: `1883`
- Authentication: Mosquitto password file
- Authorisation: Mosquitto ACL file

## Single setup command

```bash
sudo bash setup.sh
```

The setup command installs Mosquitto, applies the static IP, creates MQTT users, installs ACL rules and starts the broker.

## MQTT users

| User | Purpose | Access |
|---|---|---|
| `sensor01` | IoT sensor publisher | Write telemetry and alerts for sensor01 |
| `operator01` | Maintenance operator | Read telemetry and alerts |
| `lab_test` | Controlled lab test account | Read-only telemetry; no publish access |

Default lab passwords are in `config/credentials.env.example`. Change them before using outside the assessment lab.

## Verify

```bash
bash verify.sh
```

## Useful log command

```bash
sudo tail -f /var/log/mosquitto/mosquitto.log
```

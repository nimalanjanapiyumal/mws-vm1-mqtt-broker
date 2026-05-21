# Evidence Notes - VM1 MQTT Broker / Mosquitto

## What to capture

- Hostname: `mws-mqtt-broker`
- Static IP: `192.168.1.10/24`
- Setup command: `sudo bash setup.sh`
- Verification command: `bash verify.sh`
- Role: MQTT broker, users, password authentication, topic ACLs and broker logs

## Suggested screenshot commands

```bash
hostnamectl --static
ip -4 addr
bash verify.sh
```

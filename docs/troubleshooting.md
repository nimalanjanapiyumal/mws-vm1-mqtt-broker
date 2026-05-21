# VM1 Troubleshooting

## Mosquitto does not start

Check syntax and logs:

```bash
sudo systemctl status mosquitto --no-pager -l
sudo journalctl -u mosquitto -n 80 --no-pager
sudo mosquitto -c /etc/mosquitto/mosquitto.conf -v
```

If the error says `Duplicate persistence_location value in configuration`, make sure
`/etc/mosquitto/conf.d/mws.conf` only contains the MWS listener, authentication, ACL
and log-level settings. The main `/etc/mosquitto/mosquitto.conf` already provides
Mosquitto's default persistence and log destination settings.

If the log file or password file permissions are the cause, repair them and restart:

```bash
sudo bash scripts/create_mqtt_users.sh
sudo touch /var/log/mosquitto/mosquitto.log
sudo chown mosquitto:mosquitto /etc/mosquitto/passwd /etc/mosquitto/aclfile /var/log/mosquitto /var/log/mosquitto/mosquitto.log
sudo chmod 750 /var/log/mosquitto
sudo chmod 640 /etc/mosquitto/passwd /etc/mosquitto/aclfile /var/log/mosquitto/mosquitto.log
sudo systemctl reset-failed mosquitto
sudo systemctl restart mosquitto
```

## Clients cannot connect

Check that VM1 has the correct IP and that port 1883 is listening:

```bash
ip addr
sudo ss -lntp | grep 1883
sudo ufw status
```

## ACL does not work

Check `/etc/mosquitto/aclfile` and restart the broker:

```bash
sudo mosquitto -c /etc/mosquitto/mosquitto.conf -v
sudo systemctl restart mosquitto
```

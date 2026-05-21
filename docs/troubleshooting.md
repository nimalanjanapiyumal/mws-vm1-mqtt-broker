# VM1 Troubleshooting

## Mosquitto does not start

Check syntax and logs:

```bash
sudo mosquitto -c /etc/mosquitto/conf.d/mws.conf -v
sudo journalctl -u mosquitto -n 80 --no-pager
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
sudo mosquitto -c /etc/mosquitto/conf.d/mws.conf -v
sudo systemctl restart mosquitto
```

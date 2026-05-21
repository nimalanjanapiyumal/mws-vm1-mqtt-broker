#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo bash setup.sh"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPLY_STATIC_IP="${APPLY_STATIC_IP:-yes}"

if [ "$APPLY_STATIC_IP" = "yes" ]; then
  bash "$REPO_DIR/scripts/apply_static_ip.sh"
else
  hostnamectl set-hostname mws-mqtt-broker
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y mosquitto mosquitto-clients ufw

mkdir -p /var/log/mosquitto /etc/mosquitto/conf.d
cp "$REPO_DIR/config/mosquitto_mws.conf" /etc/mosquitto/conf.d/mws.conf
cp "$REPO_DIR/config/aclfile" /etc/mosquitto/aclfile
chown mosquitto:mosquitto /etc/mosquitto/aclfile /var/log/mosquitto
chmod 640 /etc/mosquitto/aclfile

bash "$REPO_DIR/scripts/create_mqtt_users.sh"

ufw allow from 192.168.1.0/24 to any port 1883 proto tcp || true
systemctl enable mosquitto
systemctl restart mosquitto
sleep 2
systemctl --no-pager status mosquitto || true

echo "[DONE] VM1 MQTT broker setup complete."
echo "Verify with: bash verify.sh"

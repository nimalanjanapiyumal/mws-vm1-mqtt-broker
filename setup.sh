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

MOSQUITTO_LOG_DIR="/var/log/mosquitto"
MOSQUITTO_LOG_FILE="$MOSQUITTO_LOG_DIR/mosquitto.log"

mkdir -p "$MOSQUITTO_LOG_DIR" /etc/mosquitto/conf.d
cp "$REPO_DIR/config/mosquitto_mws.conf" /etc/mosquitto/conf.d/mws.conf
cp "$REPO_DIR/config/aclfile" /etc/mosquitto/aclfile
touch "$MOSQUITTO_LOG_FILE"
chown mosquitto:mosquitto /etc/mosquitto/aclfile "$MOSQUITTO_LOG_DIR" "$MOSQUITTO_LOG_FILE"
chmod 750 "$MOSQUITTO_LOG_DIR"
chmod 640 /etc/mosquitto/aclfile "$MOSQUITTO_LOG_FILE"

bash "$REPO_DIR/scripts/create_mqtt_users.sh"

ufw allow from 192.168.1.0/24 to any port 1883 proto tcp || true
systemctl enable mosquitto
systemctl reset-failed mosquitto || true
if ! systemctl restart mosquitto; then
  echo "[ERROR] Mosquitto failed to start. Recent service logs:"
  journalctl -u mosquitto -n 80 --no-pager || true
  echo "[ERROR] Check the active config with: sudo mosquitto -c /etc/mosquitto/mosquitto.conf -v"
  exit 1
fi
sleep 2
systemctl --no-pager status mosquitto || true

echo "[DONE] VM1 MQTT broker setup complete."
echo "Verify with: bash verify.sh"

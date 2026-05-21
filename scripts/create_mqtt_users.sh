#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo bash scripts/create_mqtt_users.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CRED_FILE="$REPO_DIR/config/credentials.env"

if [ ! -f "$CRED_FILE" ]; then
  cp "$REPO_DIR/config/credentials.env.example" "$CRED_FILE"
  echo "[WARN] Created $CRED_FILE from example defaults. Change passwords for real deployments."
fi

# shellcheck disable=SC1090
source "$CRED_FILE"

PASSWD_FILE="/etc/mosquitto/passwd"
rm -f "$PASSWD_FILE"
mosquitto_passwd -b -c "$PASSWD_FILE" "$SENSOR_USER" "$SENSOR_PASSWORD"
mosquitto_passwd -b "$PASSWD_FILE" "$OPERATOR_USER" "$OPERATOR_PASSWORD"
mosquitto_passwd -b "$PASSWD_FILE" "$LAB_TEST_USER" "$LAB_TEST_PASSWORD"
chown mosquitto:mosquitto "$PASSWD_FILE"
chmod 640 "$PASSWD_FILE"

echo "[DONE] MQTT users created in $PASSWD_FILE"

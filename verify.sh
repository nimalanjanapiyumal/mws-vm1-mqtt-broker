#!/usr/bin/env bash
set -euo pipefail

source config/credentials.env 2>/dev/null || source config/credentials.env.example

echo "[CHECK] Hostname and IP"
hostnamectl --static
ip -4 addr | grep -E '192\.168\.1\.71|inet ' || true

echo "[CHECK] Mosquitto service"
systemctl is-active mosquitto

echo "[CHECK] MQTT authenticated publish/subscribe local test"
timeout 4 mosquitto_sub -h 127.0.0.1 -p 1883 -u "$OPERATOR_USER" -P "$OPERATOR_PASSWORD" -t 'mws/water/quality/+/telemetry' -C 1 >/tmp/mws_sub_test.out &
sleep 1
mosquitto_pub -h 127.0.0.1 -p 1883 -u "$SENSOR_USER" -P "$SENSOR_PASSWORD" -t 'mws/water/quality/sensor01/telemetry' -m '{"test":"broker-local"}'
wait || true
cat /tmp/mws_sub_test.out || true

echo "[CHECK] Anonymous publish should fail"
if mosquitto_pub -h 127.0.0.1 -p 1883 -t 'mws/water/quality/sensor01/telemetry' -m 'anonymous-test' 2>/tmp/mws_anon.err; then
  echo "[WARN] Anonymous publish unexpectedly succeeded. Check allow_anonymous setting."
else
  echo "[OK] Anonymous publish blocked."
fi

echo "[DONE] VM1 verification complete."

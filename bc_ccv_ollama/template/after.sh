# Wait for the LibreChat server to start
echo "Waiting for LibreChat server to open port ${LIBRE_PORT}..."
echo "TIMING - Starting wait at: $(date)"
if wait_until_port_used "${host}:${LIBRE_PORT}" 90; then
  echo "Discovered LibreChat server listening on port ${LIBRE_PORT}!"
  echo "TIMING - Wait ended at: $(date)"
else
  echo "Timed out waiting for LibreChat server to open port ${LIBRE_PORT}!"
  echo "TIMING - Wait ended at: $(date)"
  pkill -P ${SCRIPT_PID}
  clean_up 1
fi
sleep 2

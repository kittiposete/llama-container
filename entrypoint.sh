#!/bin/bash
set -e

# Check if OpenVPN config exists
if [ ! -f /vpn/client.ovpn ]; then
  echo "OpenVPN config /vpn/client.ovpn not found! Please mount it as a volume."
  exit 1
fi

# Start OpenVPN in the background
openvpn --config /vpn/client.ovpn &
VPN_PID=$!

# Wait for VPN to establish (simple check: wait for tun0)
for i in {1..20}; do
  if ip a | grep -q tun0; then
    echo "VPN connected."
    break
  fi
  echo "Waiting for VPN to connect... ($i)"
  sleep 1
done

if ! ip a | grep -q tun0; then
  echo "VPN did not connect. Exiting."
  kill $VPN_PID
  exit 2
fi

# Start the main application
if [ -z "$RPC_SERVER_ADDR" ]; then
  echo "RPC_SERVER_ADDR not set. Using default: 0.0.0.0:50052"
  exec /app/rpc-server -p 50052
else
  echo "Starting server with --rpc $RPC_SERVER_ADDR"
  exec /app/rpc-server --rpc $RPC_SERVER_ADDR
fi

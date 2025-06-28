# llama-container

This container builds and runs the `llama.cpp` RPC server, wrapped with an OpenVPN tunnel for secure networking.

## Features
- Builds `llama.cpp` from source with RPC support (no CUDA)
- Runs the server only after a VPN connection is established
- Expects an OpenVPN config file to be mounted from outside the container

## Usage

### 1. Build the Docker image
```
docker build --platform=linux/amd64 -t llama-rpc-server .
```

### 2. Run the container with your OpenVPN config
```
docker run --rm \
  -v /path/to/client.ovpn:/vpn/client.ovpn:ro \
  llama-rpc-server
```
- Replace `/path/to/client.ovpn` with the path to your OpenVPN config file on the host.

### 3. Networking
- The container will wait for the VPN connection before starting the RPC server.
- The server listens on port 50052 inside the container.

## Files
- `Dockerfile`: Multi-stage build for the server and OpenVPN setup
- `entrypoint.sh`: Entrypoint script to start OpenVPN and the server

## Notes
- The OpenVPN config must be provided at `/vpn/client.ovpn` via a bind mount.
- The container will exit if the VPN connection cannot be established.

## Example
```
docker run --rm -v $(pwd)/client.ovpn:/vpn/client.ovpn:ro llama-rpc-server
```

---

For more information on `llama.cpp`, see: https://github.com/ggml-org/llama.cpp

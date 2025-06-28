FROM debian:stable-slim

# install git and build dependencies
RUN apt-get update && \
    apt-get install -y git build-essential cmake libcurl4-openssl-dev && \
    rm -rf /var/lib/apt/lists/*

# download source via git command
RUN git clone https://github.com/ggml-org/llama.cpp.git

# compiler code
WORKDIR /llama.cpp
RUN mkdir build-rpc-cuda && \
    cd build-rpc-cuda && \
    cmake .. -DGGML_CUDA=OFF -DGGML_RPC=ON && \
    cmake --build . --config Release

# copy directory to /app
RUN mkdir /app && \
    cp -r /llama.cpp/build-rpc-cuda/* /app
WORKDIR /app


## FINAL ----IMAGE------
FROM debian:stable-slim

# install dependencies
RUN apt-get update && \
    apt-get install -y openvpn && \
    rm -rf /var/lib/apt/lists/*

# copy files from previous image
COPY --from=0 /app /app

# copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# set working directory
WORKDIR /app

# set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
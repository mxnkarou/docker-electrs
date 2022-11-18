FROM rust:1.65.0-slim as BUILD

LABEL maintainer="Max Karou <makarou@hotmail.com>"

ARG COMMIT=ce83749cc1c1bf9f56e62275d067c4391052238f
ARG REPO=https://github.com/mxnkarou/electrs.git
                                               
SHELL ["/bin/bash", "-c"]

RUN apt-get -yqq update \                                                                     
 && apt-get -yqq upgrade \                     
 && apt-get -yqq install clang cmake curl git \ 
 && git clone --no-checkout ${REPO} \
 && cd electrs \
 && git checkout ${COMMIT} \
 && cargo build --release --bin electrs

FROM debian:bullseye-slim

COPY --from=BUILD /electrs/target/release/electrs /bin/electrs

# Electrum RPC Mainnet
EXPOSE 60401 24224 3002

STOPSIGNAL SIGINT

ENTRYPOINT ["electrs", "--network", "regtest", "--daemon-rpc-addr", "host.docker.internal:18443", "-vvvv"]
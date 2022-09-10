FROM debian:stable-slim

LABEL Description="Litecoin daemon"

ARG PKG_SUM=e0bdd4aa81502551a0c5abcfaae52c8bbaf4a980548aa6c91053643d81924b51
ARG PKG_VER=0.18.1

ADD FE3348877809386C.gpg /

RUN mkdir /app /data

RUN useradd -m -d /app/litecoin-${PKG_VER}/bin litecoin -s /bin/bash

RUN apt-get -y update && \
    apt-get -y install wget gpg && \
    wget https://download.litecoin.org/litecoin-${PKG_VER}/linux/litecoin-${PKG_VER}-aarch64-linux-gnu.tar.gz && \
    #gpg --recv-key FE3348877809386C && \
    gpg --import /FE3348877809386C.gpg && \
    wget https://download.litecoin.org/litecoin-${PKG_VER}/linux/litecoin-${PKG_VER}-aarch64-linux-gnu.tar.gz.asc && \
    gpg --verify litecoin-${PKG_VER}-aarch64-linux-gnu.tar.gz.asc && \
    tar -xzf litecoin-${PKG_VER}-aarch64-linux-gnu.tar.gz -C /app && \
    rm -rf litecoin-${PKG_VER}-aarch64-linux-gnu.* && \
    # Removing some vulnerable and not used packages
    apt-get -y remove libext2fs2 libss2 logsave e2fsprogs wget gpg --allow-remove-essential

RUN chown -R litecoin. /app /data
WORKDIR /app/litecoin-${PKG_VER}/bin

USER litecoin

ENTRYPOINT [ "./litecoind" ]

FROM alpine:edge

RUN set -ex && \
  addgroup -S miner && \
  adduser -S -D -h /xmrig -G miner miner && \
  apk --no-cache upgrade && \
  apk --no-cache add hwloc hwloc-dev --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ && \
  apk --no-cache add \
    openssl \
    libuv \
    libmicrohttpd && \
  apk --no-cache add --virtual .build-deps \
    git \
    cmake \
    libuv-dev \
    libmicrohttpd-dev \
    openssl-dev \
    build-base && \
  cd xmrig && \
  git clone https://github.com/MoneroOcean/xmrig build && \
  cd build && \
  git checkout v4.3.1-beta-mo2 && \
  sed -i 's/kDefaultDonateLevel = 5/kDefaultDonateLevel = 0/' src/donate.h && \
  sed -i 's/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/' src/donate.h && \
  cmake -DCMAKE_BUILD_TYPE=Release . && \
  make && \
  cd .. && \
  cp build/xmrig /usr/bin && \
  rm -rf build && \
  apk del .build-deps hwloc-dev || return 0

USER miner
WORKDIR /xmrig
ENTRYPOINT ["/usr/bin/xmrig"]

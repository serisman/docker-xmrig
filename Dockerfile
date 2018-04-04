FROM alpine:3.7

RUN set -ex && \
  addgroup -S miner && \
  adduser -S -D -h /xmrig -G miner miner && \
  apk --no-cache upgrade && \
  apk --no-cache add \
    libuv \
    libmicrohttpd && \
  apk --no-cache add --virtual .build-deps \
    git \
    cmake \
    libuv-dev \
    libmicrohttpd-dev \
    build-base && \
  cd xmrig && \
  git clone https://github.com/xmrig/xmrig build && \
  cd build && \
  git checkout v2.6.0-beta1 && \
  sed -i 's/kDonateLevel = 5/kDonateLevel = 0/' src/donate.h && \
  sed -i 's/(arg < 1 || arg > 99)/(arg < 0 || arg > 99)/g' src/Options.cpp && \
  cmake -DCMAKE_BUILD_TYPE=Release . && \
  make && \
  cd .. && \
  cp build/xmrig /usr/bin && \
  rm -rf build && \
  apk del .build-deps || return 0

USER miner
WORKDIR /xmrig
ENTRYPOINT ["/usr/bin/xmrig"]

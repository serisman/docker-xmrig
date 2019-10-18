FROM alpine:edge as build

RUN apk --no-cache add git build-base cmake openssl-dev libuv-dev
RUN apk --no-cache add hwloc-dev --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

WORKDIR /build
RUN git clone https://github.com/MoneroOcean/xmrig

WORKDIR /build/xmrig
RUN git checkout v4.3.1-beta-mo2
RUN sed -i 's/kDefaultDonateLevel = 5/kDefaultDonateLevel = 0/' src/donate.h
RUN sed -i 's/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/' src/donate.h
RUN cmake -DCMAKE_BUILD_TYPE=Release .
RUN make

#---------------------------------------------------------------------
FROM alpine:edge

RUN addgroup -S miner && \
  adduser -S -D -h /xmrig -G miner miner && \
  apk --no-cache add libssl1.1 libuv && \
  apk --no-cache add hwloc --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/
COPY --from=build /build/xmrig/xmrig /usr/bin

USER miner
WORKDIR /xmrig
ENTRYPOINT ["/usr/bin/xmrig"]

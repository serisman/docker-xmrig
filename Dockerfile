FROM alpine:edge as build

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
RUN apk --no-cache add coreutils git build-base cmake openssl-dev libuv-dev hwloc-dev

WORKDIR /build
RUN git clone https://github.com/MoneroOcean/xmrig

WORKDIR /build/xmrig
RUN git checkout v5.0.0-mo1
RUN sed -i 's/kDefaultDonateLevel = 5/kDefaultDonateLevel = 0/' src/donate.h
RUN sed -i 's/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/' src/donate.h
RUN cmake -DCMAKE_BUILD_TYPE=Release .
RUN make -j$(getconf _NPROCESSORS_ONLN)

#---------------------------------------------------------------------
FROM alpine:edge

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
RUN apk --no-cache add coreutils libssl1.1 libuv hwloc
RUN addgroup -S miner && adduser -S -D -h /xmrig -G miner miner

COPY --from=build /build/xmrig/xmrig /usr/bin

USER miner
WORKDIR /xmrig
ENTRYPOINT ["/bin/nice", "-n19", "/usr/bin/xmrig"]

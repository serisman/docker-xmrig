FROM alpine:edge

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
RUN apk --no-cache add coreutils libssl1.1 libuv hwloc
RUN addgroup -S miner && adduser -S -D -h /xmrig -G miner miner

COPY xmrig /usr/bin
RUN chmod +x /usr/bin/xmrig

USER miner
WORKDIR /xmrig
ENTRYPOINT ["/bin/nice", "-n19", "/usr/bin/xmrig"]

## this stage installs everything required to build the project
FROM alpine:3.9 as build
RUN apk add --no-cache alpine-sdk yaml-dev openssl-dev crystal shards upx
WORKDIR /tmp
COPY shard.* /tmp/
COPY ./src /tmp/src
RUN \
    shards install && \
    crystal build --progress --static src/redis-test.cr -o /tmp/redis-test && \
    upx /tmp/redis-test


## this stage created final docker image
FROM busybox as release
COPY --from=build /tmp/redis-test /redis-test
USER nobody
ENTRYPOINT ["/redis-test"]

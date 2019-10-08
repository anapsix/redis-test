# redis-test

Insert random 8 character hex key with random 512 character value into local Redis instance.

## Build
```
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/openssl/lib/pkgconfig
shards build
ls -la ./bin
```

## Usage
```
./bin/redis-test
# [CRTL-C] to stop
```


# unit-php
Alpine based Docker image for nginx-unit with PHP module

Ready-to-use images:
```shell
ghcr.io/n0rthernl1ghts/unit-php
```
**Warning:** Docker Hub images are deprecated and no longer maintained due to their hostility towards open-source community.

Supported PHP versions:
- PHP7.4
- PHP8.1
- PHP8.2

Check the [package](https://github.com/N0rthernL1ghts/unit-php/pkgs/container/unit-php) for available tags.

Currently under active maintenance, so to be considered as unstable.


#### How to use
On container startup, unit is launched and then config.json is sent to the service.  
<br></br>
[Bundled config](rootfs/etc/unit/config.json) is suitable for running simple Laravel application in `/app`. Keep in mind persistent directories, if any.
```shell
docker run -it \
  -v "/path/to/your/laravel_app:/app" \
  ghcr.io/n0rthernl1ghts/unit-php
```

And here's how to run with your own config:
```shell
docker run -it \
  -v "/path/to/your/unit_config.json:/etc/unit/config.json" \
  -v "/path/to/your/web_app:/app" \
  ghcr.io/n0rthernl1ghts/unit-php
```

You can also override path to unit configuration file with `UNIT_CONFIGURATION_FILE` environment variable:
```shell
docker run -it \
  -e "UNIT_CONFIGURATION_FILE=/app/config/unit.json" \
  -v "/path/to/your/web_app:/app" \
  ghcr.io/n0rthernl1ghts/unit-php
```

###### Extending the image

Example ```multistage``` Dockerfile:
```dockerfile
# First stage: Build root filesystem (copy files)
FROM scratch AS rootfs

COPY ["./app", "/app"]
COPY ["./unit.json", "/etc/unit/config.json"]



# Main stage
FROM ghcr.io/n0rthernl1ghts/unit-php

# Copy prepared root filesystem (single layer)
COPY --from=rootfs ["/", "/"]

# Install PHP extensions with pecl: apcu and redis
# Install PHP extension: opcache, pdo and pdo_mysql
RUN set -eux \
    && apk add --update --no-cache alpine-sdk \
    && pear channel-update pear.php.net \
    && pecl channel-update pecl.php.net \
    && pecl install apcu redis \
    && docker-php-ext-enable apcu redis \
    && docker-php-ext-install -j "$(nproc)" opcache pdo pdo_mysql \
    && apk del alpine-sdk \
    && rm /tmp/* -rf
```

#### Docker Secrets
You can use Docker secrets to pass sensitive data to the container.
Secrets are natively mounted in `/run/secrets` directory, but internal service will normalize them.

Eg. `/run/secrets/db_password` will be normalized to `/run/secrets_normalized/DB_PASSWORD` and passed as `DB_PASSWORD` environment variable to the service.  

For security reasons, secrets are not available in global environment, but only in the service's environment.

Example using docker-compose.yml
```yaml
secrets:
  db_password:
    file: ./secrets/db_password
    
services:
  app:
    image: ghcr.io/n0rthernl1ghts/unit-php:latest
    secrets:
      - db_password # Available as DB_PASSWORD under unit's environment
```

#### Supervisor
This image comes bundled with [just-containers/s6-overlay](https://github.com/just-containers/s6-overlay) from build [ghcr.io/n0rthernl1ghts/s6-rootfs](https://github.com/N0rthernL1ghts/s6-rootfs).
To control supervisor behavior, you can use [it's environment variables](https://github.com/just-containers/s6-overlay#customizing-s6-behaviour).
<br></br>

Do NOT attempt starting with docker built-in supervisor (Tini [--init]). S6 must run as PID 1.

#### Caveats
- Comes with PHP ZTS (Zend Thread Safety) enabled. The reason behind is that official PHP image, doesn't support PHP embed on Alpine based images. See: https://github.com/docker-library/php/pull/1355. It does, however on ZTS Alpine images.

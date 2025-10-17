#################################################
# STAGE: Map rcourtman/pulse:[version] to pulse #
#################################################
ARG PULSE_VERSION="4.24.0"
FROM ghcr.io/rcourtman/pulse-docker-agent:${PULSE_VERSION} AS pulse



#################################################
# STAGE: Adapt docker-env-secrets for no s6     #
#################################################
FROM alpine:3.22 AS docker-env-secrets

# Install init-docker-secrets service
COPY --from=ghcr.io/n0rthernl1ghts/docker-env-secrets:latest ["/", "/rootfs-build/"]

# Remove S6 Overlay specific files
RUN set -eux \
    && rm -rfv "/rootfs-build/etc/s6-overlay/"



#################################################
# STAGE: Build rootfs                           #
#################################################
FROM scratch AS rootfs

# Install pulse-docker-agent
COPY --chmod=0777 --from=pulse ["/usr/local/bin/pulse-docker-agent", "/usr/local/bin/pulse-docker-agent"]

# Copy entrypoint
COPY ["./src/pulse-entrypoint.sh", "/"]

# Install docker-env-secrets
COPY --from=docker-env-secrets ["/rootfs-build/", "/"]

# Add copy of Pulse license (MIT)
ADD ["https://raw.githubusercontent.com/rcourtman/Pulse/refs/heads/main/LICENSE", "/opt/pulse/LICENSE"]



#################################################
# STAGE: Build main image                       #
#################################################
FROM alpine:3.22

RUN set -eux \
    && apk add --no-cache bash

COPY --from=rootfs ["/", "/"]

ARG PULSE_VERSION
ENV SECRETS_EXPORT_PATH=/run/secrets_normalized \
    NORMALIZE_SECRET_NAMES=1 \
    PULSE_VERSION="${PULSE_VERSION}" \
    PULSE_DOCKER="true"

ENTRYPOINT ["/pulse-entrypoint.sh"]
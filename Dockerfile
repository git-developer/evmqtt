ARG BUILD_FROM=ghcr.io/home-assistant/base-python

# Build stage for Python package
FROM python:3-alpine AS builder
RUN apk add --no-cache linux-headers gcc libc-dev
WORKDIR /build
COPY pyproject.toml ./
COPY src/ src/
RUN pip install --no-cache-dir --prefix=/install .

# Final stage - Home Assistant Add-on or standalone
FROM ${BUILD_FROM}
ARG BUILD_NAME=evmqtt
ARG BUILD_DESCRIPTION="Linux input event to MQTT gateway"
ARG BUILD_VERSION=0.0.0-latest

# Install evmqtt package
COPY --from=builder /install /usr/local

# Copy entrypoint
COPY run.sh /
RUN chmod a+x /run.sh

# Set working directory
WORKDIR /data

# Add labels for Home Assistant
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="addon"

CMD ["/run.sh"]

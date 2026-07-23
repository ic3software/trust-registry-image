FROM ubuntu:26.04

ARG TRUST_REGISTRY_VERSION=0.8.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://fpp.ic3.dev/trust-registry-k8s/${TRUST_REGISTRY_VERSION}/trust-registry" -o /usr/local/bin/trust-registry && \
    chmod 0755 /usr/local/bin/trust-registry

WORKDIR /app/trust-registry

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

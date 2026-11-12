FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

ENV ACME_PACKAGED=1

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.51/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA256SUM=cc232108374e8e2b537045f2d5eaa1229f619db314c3ba6a14d38b35dc0aa123

# Install packages and create user/group
RUN apk --no-cache add -f \
    shadow \
    openssl \
    openssh-client \
    coreutils \
    bind-tools \
    curl \
    sed \
    socat \
    tzdata \
    oath-toolkit-oathtool \
    tar \
    libidn \
    jq \
    yq-go \
    gosu \
    # Install supercronic
    && curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA256SUM}  ${SUPERCRONIC}" | sha256sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic \
    # Create user
    && addgroup acme \
    && adduser -D -s /sbin/nologin -G acme acme

# Install acme.sh
COPY root/ /

ENTRYPOINT ["/opt/preflight.sh"]
CMD ["/opt/run.sh"]

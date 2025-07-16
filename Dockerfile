FROM alpine:3.22.1@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1

# Add labels for better maintainability
LABEL maintainer="Ducktors <https://github.com/ducktors/docker-wait-for-dependencies>"
LABEL description="A lightweight container to wait for service dependencies to become available"

# Install required packages and create non-root user
RUN apk add --no-cache \
    bash \
    netcat-openbsd \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /usr/local/bin

# Copy and set up the entrypoint script
COPY --chown=appuser:appgroup entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to non-root user
USER appuser

# Set environment variables with defaults
ENV SLEEP_LENGTH=2 \
    TIMEOUT_LENGTH=300

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

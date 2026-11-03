FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

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

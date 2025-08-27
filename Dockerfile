FROM alpine:3.22

LABEL Maintainer="Ernesto Serrano <info@ernesto.es>" \
      Description="Lightweight container with Chromium browser & ChromeDriver based on Alpine Linux."

LABEL org.opencontainers.image.title="Chromium + ChromeDriver (Alpine)"
LABEL org.opencontainers.image.description="Headless Chromium with ChromeDriver on Alpine Linux."
LABEL org.opencontainers.image.authors="Ernesto Serrano <info@ernesto.es>"
LABEL org.opencontainers.image.licenses="MIT"

# Prefer POSIX shell with pipefail
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Install runtime packages
RUN apk --no-cache add \
      chromium-chromedriver \
      curl \
      dumb-init \
    && addgroup -g 65534 -S nobody || true \
    && adduser -S -H -D -u 65534 -G nobody nobody || true \
    && install -d -m 1777 /tmp \
    && install -d -o nobody -g nobody /run \
    && install -d -o nobody -g nobody /var/www/html \
    && install -d -o nobody -g nobody /home/nobody/.cache/chromium \
    && install -d -o nobody -g nobody /home/nobody/.config/chromium \
    && install -d -o nobody -g nobody /home/nobody/.local/share/applications \
    && install -d -o nobody -g nobody /tmp/.X11-unix

# Environment for Chromium/Driver
ENV HOME=/home/nobody \
    CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/bin/chromium-browser \
    CHROMEDRIVER_BIN=/usr/bin/chromedriver \
    DISPLAY=:99 \
    XDG_CACHE_HOME=/home/nobody/.cache \
    XDG_CONFIG_HOME=/home/nobody/.config \
    XDG_DATA_HOME=/home/nobody/.local/share \
    CHROMIUM_FLAGS="--headless=new --no-sandbox --disable-dev-shm-usage --disable-gpu --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding"

# Expose ChromeDriver port
EXPOSE 9515

# Healthcheck: verifica endpoint y "ready": true
HEALTHCHECK --interval=30s --timeout=15s --start-period=10s --retries=3 \
  CMD curl --silent --fail --connect-timeout 5 -H "Origin: http://localhost" http://127.0.0.1:9515/status \
    | grep -q '"ready":[[:space:]]*true' || exit 1

# Use dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Default command: ChromeDriver verbose y orígenes permitidos
CMD ["/usr/bin/chromedriver", \
     "--port=9515", \
     "--allowed-origins=*", \
     "--whitelisted-ips=", \
     "--verbose", \
     "--log-path=-"]
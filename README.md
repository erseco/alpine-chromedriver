# Docker Chromium + ChromeDriver on Alpine Linux 3.22

[![Docker Pulls](https://img.shields.io/docker/pulls/erseco/alpine-chromedriver.svg)](https://hub.docker.com/r/erseco/alpine-chromedriver/)
![Docker Image Size](https://img.shields.io/docker/image-size/erseco/alpine-chromedriver)
![alpine 3.22](https://img.shields.io/badge/alpine-3.22-brightgreen.svg)
![chromium](https://img.shields.io/badge/chromium-latest-brightgreen.svg)
![chromedriver](https://img.shields.io/badge/chromedriver-latest-brightgreen.svg)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

Lightweight Docker image with [Chromium](https://www.chromium.org/) browser and [ChromeDriver](https://chromedriver.chromium.org/) based on [Alpine Linux](https://www.alpinelinux.org/).

Repository: [https://github.com/erseco/alpine-chromedriver](https://github.com/erseco/alpine-chromedriver)

* Built on the lightweight Alpine Linux distribution
* Includes both Chromium and ChromeDriver
* Small Docker image size
* Runs under non-root user (`nobody`)
* Multi-arch support (amd64, arm64, …)
* Ready for Selenium, Puppeteer, Playwright or direct WebDriver usage
* Uses `dumb-init` to properly handle signals and avoid zombie processes
* Healthcheck to validate ChromeDriver is responding

---

## Usage

Start the Docker container and expose ChromeDriver port (default: 9515):

```bash
docker run -p 9515:9515 erseco/alpine-chromedriver
```

Check ChromeDriver status:

```bash
curl http://localhost:9515/status
```

Expected output includes `"ready": true`.

---

## Running with Docker Compose

Example `docker-compose.yml`:

```yaml
services:
  chromedriver:
    image: erseco/alpine-chromedriver
    ports:
      - "9515:9515"
    restart: unless-stopped
```

* **image**: Uses `erseco/alpine-chromedriver`.
* **ports**: Maps ChromeDriver’s port 9515 to your host.
* **restart**: Ensures the container is always available unless manually stopped.

---

## Environment variables

The image defines some environment variables to simplify usage:

| Variable           | Default                                                  | Description                                |
| ------------------ | -------------------------------------------------------- | ------------------------------------------ |
| `CHROME_BIN`       | `/usr/bin/chromium-browser`                              | Path to Chromium binary                    |
| `CHROME_PATH`      | `/usr/bin/chromium-browser`                              | Alias to Chromium binary                   |
| `CHROMEDRIVER_BIN` | `/usr/bin/chromedriver`                                  | Path to ChromeDriver binary                |
| `CHROMIUM_FLAGS`   | `--no-sandbox --disable-dev-shm-usage --disable-gpu ...` | Default flags for Chromium (headless-safe) |
| `DISPLAY`          | `:99`                                                    | Default display for X11/headless           |

When using Selenium or Puppeteer, ensure your client passes `CHROMIUM_FLAGS` if required.

---

## Healthcheck

The container includes a healthcheck that queries ChromeDriver:

```bash
curl http://localhost:9515/status
```

If ChromeDriver is not responding with `"ready": true`, the container will be marked as unhealthy.

---

## Logs

By default, ChromeDriver runs with `--verbose` and logs to stdout:

```bash
docker logs -f <container_name>
```

---

## Example: Run Selenium tests against this container

```yaml
services:
  chromedriver:
    image: erseco/alpine-chromedriver
    ports:
      - "9515:9515"

  tests:
    image: selenium/standalone-tests
    environment:
      - WEBDRIVER_URL=http://chromedriver:9515
    depends_on:
      - chromedriver
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.

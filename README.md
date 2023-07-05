### Run the Otel Collector as a Container

```bash
docker run \
  --rm \
  -p 4317:4317 \
  -v "${PWD}"/otel-config/otel-collector-config.yaml:/etc/otelcol-contrib/config.yaml \
  -v "${PWD}"/metricsoutput:/var/log \
  otel/opentelemetry-collector-contrib:0.78.0
```

### Build the Flask App Container

```bash
docker build -t simpleflaskapp .
```

### Run the Flask App Container

```bash
docker run --rm -p 5000:5000 simpleflaskapp
```

### Run both Containers with Docker Compose (Builds the Flask App Container Automatically each time)

```bash
docker-compose up --build
```

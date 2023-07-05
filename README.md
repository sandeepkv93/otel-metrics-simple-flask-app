### Run the Otel Collector as a Container

```bash
docker run \
  --rm \
  -p 4317:4317 \
  -v "${PWD}"/otel-config/otel-collector-config.yaml:/etc/otelcol-contrib/config.yaml \
  -v "${PWD}"/metricsoutput:/var/log \
  otel/opentelemetry-collector-contrib:0.78.0
```

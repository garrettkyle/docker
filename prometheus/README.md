# Prometheus

Main config file is called `prometheus.yaml`


Example `rule_files:` entry in the `prometheus.yaml` file:
```
rule_files:
  - "application_alerts.yaml"
  - "system_alerts.yaml"
```

Example alert rule file:
```
# system_alerts.yaml
groups:
  - name: cpu_high_usage_alert
    rules:
      - alert: HighCPUUsage
        expr: avg(rate(cpu_usage_seconds_total[5m])) by (instance) > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High CPU usage on instance {{ $labels.instance }}"
          description: "CPU usage on instance {{ $labels.instance }} is over 90% for more than 5 minutes."
```

As of Prometheus 3.x you can use the following config block
```
scrape_config_files:
  - "scrape_config.yml"
```

This allows you to automatically read in from the specified `.yaml` file instead of storing all your scrape configs within the `prometheus.yaml` file itself.

Example `scrape_config.yaml` file:

```
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
```

This scrape config file will tell Prometheus to scrape metrics from the localhost via `node_exporter` which would be running as a container on the same host as the Prometheus container and would be exposed on port `9100`.

The scrape config file(s) is where you configure your targets to be scraped and via what mechanism.  You can also specify overrides for global parameter declared in the `prometheus.yaml` file `global:` section.
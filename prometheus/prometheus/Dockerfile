FROM prom/prometheus:latest
ADD prometheus.yaml /etc/prometheus/
ADD scrape_config.yaml /etc/prometheus/
ADD system_alerts.yaml /etc/prometheus/
RUN touch /prometheus/prometheus_query.log \ 
    && chmod 755 /prometheus/prometheus_query.log
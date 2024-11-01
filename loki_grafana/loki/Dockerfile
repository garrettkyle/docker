FROM alpine:latest

WORKDIR /git

RUN apk update \
    && apk add --update --no-cache \
    libc6-compat wget unzip \
    && wget https://github.com/grafana/loki/releases/download/v3.2.1/loki-linux-amd64.zip \
    && unzip loki-linux-amd64.zip \
    && rm -f loki-linux-amd64.zip \
    && mkdir -p /etc/loki/

COPY local-config.yaml /etc/loki/local-config.yaml

CMD ["./loki-linux-amd64", "-config.expand-env=true", "-config.file=/etc/loki/local-config.yaml"]
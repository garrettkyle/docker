FROM alpine:latest

RUN apk update \
    && apk add --no-cache \
        bash \
        curl \
        ca-certificates \
    && update-ca-certificates

ENV THANOS_VERSION=v0.36.1

RUN curl -LO https://github.com/thanos-io/thanos/releases/download/v0.36.1/thanos-0.36.1.linux-amd64.tar.gz \
    && tar -xvzf thanos-0.36.1.linux-amd64.tar.gz \
    && mv thanos-0.36.1.linux-amd64/thanos /usr/local/bin/ \
    && rm -rf thanos-0.36.1-linux-amd64*

EXPOSE 10902

RUN mkdir -p /etc/thanos

COPY storage.yaml /etc/thanos/storage.yaml

CMD ["thanos"]
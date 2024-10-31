FROM alpine:latest

WORKDIR /git

RUN apk update \
    && apk add --update --no-cache \
    loki-promtail git openssh-client

COPY promtail.yaml /etc/promtail/promtail.yaml

CMD ["promtail", "-config.file=/etc/promtail/promtail.yaml"]
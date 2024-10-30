FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    git \
    python3-venv \
    python3-pip \
    && apt-get clean

WORKDIR /git

RUN python3 -m venv venv

RUN . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install awscli boto3

ENV PATH="/git/venv/bin:${PATH}"
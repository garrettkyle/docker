FROM alpine:latest

# Launch using this command to have it automatically pick up local AWS CLI and SSH credentials
# docker run -it -v $HOME/.aws:/root/.aws:ro -v $HOME/.ssh:/root/.ssh:ro <CONTAINER_IMAGE_NAME>
RUN apk update && \
    apk add --update --no-cache \
    bash curl git jq \
    python3 zip unzip wget vim \
    openssl ca-certificates aws-cli

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf /aws

RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv && \
    ln -s ~/.tfenv/bin/* /usr/local/bin

# Install terraform
RUN tfenv install latest && \
    tfenv use latest

VOLUME ["/data"]
WORKDIR /workdir
ARG DEBIAN_FRONTEND=noninteractive
FROM debian:stable

# Launch using this command to have it automatically pick up local AWS CLI and SSH credentials
# docker run -it -v ~/.aws:/root/.aws -v ~/.ssh:/root/.ssh <CONTAINER_IMAGE_NAME>
# Install dependencies and cleanup afterward
RUN apt update && \
    apt upgrade -y && \
    apt-get install -y \
    curl \
    git \
    wget \
    gpg \
    unzip \
    apt-transport-https \
    ca-certificates \
    software-properties-common && \
    # Clean up APT when done to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Install terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && \
    apt install terraform -y
# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -f awscliv2.zip && \
    apt autoremove && \
    apt clean && \
    rm -rf /aws && \
    mkdir /git
#EXPOSE 80/tcp
#ENV MY_NAME="John Doe"
VOLUME ["/data"]
WORKDIR /workdir
# Use the Debian stable slim image as the base
FROM debian:stable-slim

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-venv \
    python3-pip \
    && apt-get clean

# Create a directory for the application
WORKDIR /app

# Create a virtual environment
RUN python3 -m venv venv

# Activate the virtual environment and install AWS CLI and Boto3
RUN . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install awscli boto3

# Set the PATH to include the virtual environment's bin directory
ENV PATH="/app/venv/bin:${PATH}"

# Verify installations
RUN aws --version && python -m pip show boto3

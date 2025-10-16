FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    ca-certificates \
    jq \
    helm \
    && wget https://github.com/mikefarah/yq/releases/download/v4.13.4/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

WORKDIR /app

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y zsh git curl stow build-essential procps sudo && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user (ubuntu) with sudo privileges
RUN useradd -m -s /bin/zsh ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ubuntu
WORKDIR /workspace

# Install Homebrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Set Homebrew environment variables
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"

# Pre-install stow via brew so it's ready for testing
RUN brew install stow

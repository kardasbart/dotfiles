FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y sudo curl git

RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Copy whole repository into temporary location
COPY --chown=testuser:testuser . /tmp/dotfiles-repo

# Ensure scripts have execution permissions
RUN chmod +x /tmp/dotfiles-repo/*.sh

# Build argument to switch between remote and local test mode
ARG LOCAL=false

# Run setup using bash explicitly
RUN if [ "$LOCAL" = "true" ]; then \
        bash /tmp/dotfiles-repo/setup.sh --local /tmp/dotfiles-repo; \
    else \
        bash /tmp/dotfiles-repo/setup.sh; \
    fi

CMD ["/tmp/dotfiles-repo/test.sh"]
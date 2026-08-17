FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install sudo, curl, and git
RUN apt-get update && apt-get install -y sudo curl git

# Create a non-root user with passwordless sudo permissions
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Copy setup script and test script into container
COPY --chown=testuser:testuser setup.sh /home/testuser/setup.sh
COPY --chown=testuser:testuser test.sh /home/testuser/test.sh

RUN chmod +x /home/testuser/setup.sh /home/testuser/test.sh

# Execute setup script during container build
RUN /home/testuser/setup.sh

# Run test suite by default
CMD ["/home/testuser/test.sh"]
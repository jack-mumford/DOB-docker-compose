# Using the .NET runtime-deps image
FROM mcr.microsoft.com/dotnet/runtime-deps:10.0-preview

# Install dependencies
RUN apt update && apt upgrade -y
RUN apt install -y curl && apt-get install -y jq

# Create a non-root user first
RUN useradd -m -u 1001 GHA

# Set working directory in user's home
RUN mkdir -p /home/GHA/actions-runner
WORKDIR /home/GHA/actions-runner

# Download the latest runner package
RUN curl -O -L https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-linux-arm64-2.325.0.tar.gz

# Extract the installer
RUN tar xzf ./actions-runner-linux-arm64-2.325.0.tar.gz

# Copy the entrypoint script
ADD scripts/start.sh /home/GHA/actions-runner/start.sh

# Make the script executable
RUN chmod +x ./start.sh

# Switch to the non-root user
USER GHA

# Set the entrypoint
ENTRYPOINT ["/home/GHA/actions-runner/start.sh"]
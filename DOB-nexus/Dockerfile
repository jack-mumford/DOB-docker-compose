FROM eclipse-temurin:8-jre AS builder

RUN apt update && apt install -y \
    curl \
    tar \
    bash

RUN curl -fsSL "https://download.sonatype.com/nexus/3/nexus-3.81.1-01-linux-aarch_64.tar.gz" -o /tmp/nexus.tar.gz
RUN mkdir -p /opt

RUN tar -xzf /tmp/nexus.tar.gz -C /opt \
    && mv /opt/nexus-3.81.1-01 /opt/nexus \
    && mv /opt/sonatype-work/nexus3 /nexus-data

RUN useradd nexus

RUN chown -R nexus:nexus /opt/nexus \
    && chown -R nexus:nexus /nexus-data \
    && chown -R nexus:nexus /opt/sonatype-work

RUN sed -i 's/-Xms2703m/-Xms1200m/g' /opt/nexus/bin/nexus.vmoptions \
    && sed -i 's/-Xmx2703m/-Xmx1200m/g' /opt/nexus/bin/nexus.vmoptions \
    && sed -i 's/-XX:MaxDirectMemorySize=2703m/-XX:MaxDirectMemorySize=4g/g' /opt/nexus/bin/nexus.vmoptions \
    && echo "-Djava.util.prefs.userRoot=/nexus-data/nexus3/javaprefs" >> /opt/nexus/bin/nexus.vmoptions

FROM eclipse-temurin:8-jre AS runner

# Copy application files
COPY --from=builder /opt/nexus /opt/nexus
COPY --from=builder /nexus-data /nexus-data
COPY --from=builder /opt/sonatype-work /opt/sonatype-work

# Create nexus user in the final stage
RUN useradd -r -u 997 -m -c "nexus role account" -d /nexus-data -s /bin/false nexus

# Set up GitHub Actions runner directory
RUN mkdir -p /opt/actions-runner
WORKDIR /opt/actions-runner

# Download and extract GitHub Actions runner
RUN curl -o actions-runner-linux-arm64-2.325.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-linux-arm64-2.325.0.tar.gz \
    && tar -xzf actions-runner-linux-arm64-2.325.0.tar.gz \
    && rm actions-runner-linux-arm64-2.325.0.tar.gz

# Set proper ownership for all directories
RUN chown -R nexus:nexus /opt/nexus \
    && chown -R nexus:nexus /nexus-data \
    && chown -R nexus:nexus /opt/sonatype-work \
    && chown -R nexus:nexus /opt/actions-runner

# Switch to nexus user
USER nexus

# Set working directory back to nexus
WORKDIR /opt/nexus

# Expose Nexus port
EXPOSE 8081

# Set up volume
VOLUME ["/nexus-data"]

# Environment variables
ENV NEXUS_DATA="/nexus-data" \
    NEXUS_CONTEXT="" \
    SONATYPE_WORK="/opt/sonatype-work"

# Start Nexus
CMD ["/opt/nexus/bin/nexus", "run"]
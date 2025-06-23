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
    && sed -i 's/-XX:MaxDirectMemorySize=2703m/-XX:MaxDirectMemorySize=2g/g' /opt/nexus/bin/nexus.vmoptions \
    && echo "-Djava.util.prefs.userRoot=/nexus-data/nexus3/javaprefs" >> /opt/nexus/bin/nexus.vmoptions

FROM eclipse-temurin:8-jre AS runner

# Copy application files
COPY --from=builder /opt/nexus /opt/nexus
COPY --from=builder /nexus-data /nexus-data

RUN useradd nexus
USER nexus

EXPOSE 8081
VOLUME /nexus-data

ENV NEXUS_DATA="/nexus-data"
CMD ["/opt/nexus/bin/nexus", "run"]
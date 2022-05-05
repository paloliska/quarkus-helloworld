FROM debian:buster-slim as builder

# External package versions
ENV GRAALVM_VERSION=22.1.0
ENV OPENJDK_VERSION=11
ENV MAVEN_VERSION=3.8.4

# Environment variables
ENV JAVA_HOME="/opt/graalvm-ce-java$OPENJDK_VERSION-$GRAALVM_VERSION"
ENV MAVEN_HOME="/opt/apache-maven-$MAVEN_VERSION"
ENV PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH"

RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install build-essential libz-dev zlib1g-dev curl \
  && apt-get -y autoremove \
  && apt-get -y clean


RUN curl -s -L "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$GRAALVM_VERSION/graalvm-ce-java$OPENJDK_VERSION-linux-amd64-$GRAALVM_VERSION.tar.gz" -o "graalvm-ce-java$OPENJDK_VERSION-linux-amd64-$GRAALVM_VERSION.tar.gz" \
  && curl -s -L "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$GRAALVM_VERSION/graalvm-ce-java$OPENJDK_VERSION-linux-amd64-$GRAALVM_VERSION.tar.gz.sha256" -o "graalvm-ce-java$OPENJDK_VERSION-linux-amd64-$GRAALVM_VERSION.tar.gz.sha256" \
  && echo "$(cat graalvm-ce-java$OPENJDK_VERSION-linux-amd64-$GRAALVM_VERSION.tar.gz.sha256)  graalvm-ce-java$OPENJDK_VERSION-linux-amd64-$GRAALVM_VERSION.tar.gz" | sha256sum -c \
  && tar -xzf "graalvm-ce-java$OPENJDK_VERSION-linux-amd64-$GRAALVM_VERSION.tar.gz" -C /opt \
  && gu install native-image \
  && rm -f graalvm-ce-*.tar.gz*

RUN curl -s -L "https://maven.apache.org/download.cgi?action=download&filename=maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" -o "apache-maven-$MAVEN_VERSION-bin.tar.gz" \
  && curl -s -L "https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz.sha512" -o "apache-maven-$MAVEN_VERSION-bin.tar.gz.sha512" \
  && echo "$(cat apache-maven-$MAVEN_VERSION-bin.tar.gz.sha512)  apache-maven-$MAVEN_VERSION-bin.tar.gz" | sha512sum -c \
  && tar -xzf "apache-maven-$MAVEN_VERSION-bin.tar.gz" -C /opt \
  && rm -f apache-maven*.tar.gz*

# Set workspace
RUN mkdir /workspace \
  && ln -s /workspace /project
WORKDIR /workspace

# Run as new user
RUN useradd -s /sbin/nologin -m mvn
RUN chown mvn:mvn /workspace
USER mvn

RUN mvn -DskipTests clean package -Pnative

FROM registry.fedoraproject.org/fedora-minimal

COPY --from=builder /project/target/helloworld-java-quarkus-1.0-SNAPSHOT-runner /app

ENTRYPOINT [ "/app" ]

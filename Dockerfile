#FROM instructure/graalvm-ce:21-java11 as builder
FROM ghcr.io/graalvm/jdk:ol8-java11 as builder
#FROM ghcr.io/graalvm/graalvm-ce:ol8-java11-22.1.0 as builder
COPY . /project
RUN dnf install maven

# uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
# ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
# e.g.
# ARG MAVEN_MIRROR_URL=http://192.168.64.1:8081/nexus/content/groups/public

RUN mvn -DskipTests clean package -Pnative

FROM registry.fedoraproject.org/fedora-minimal

COPY --from=builder /project/target/helloworld-java-quarkus-1.0-SNAPSHOT-runner /app

ENTRYPOINT [ "/app" ]

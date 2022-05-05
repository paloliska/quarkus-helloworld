FROM instructure/graalvm-ce:21-java11 as builder
COPY . /project
RUN yum update -y
RUN yum install wget -y
RUN wget https://www-eu.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz -P /tmp
RUN tar xf /tmp/apache-maven-3.6.1-bin.tar.gz -C /opt
RUN ln -s /opt/apache-maven-3.6.1 /opt/maven
#RUN ln -s /opt/graalvm-ce-1.0.0-rc16 /opt/graalvm

ENV JAVA_HOME=/opt/graalvm
ENV M2_HOME=/opt/maven
ENV MAVEN_HOME=/opt/maven
ENV PATH=${M2_HOME}/bin:${PATH}
ENV PATH=${JAVA_HOME}/bin:${PATH}

# uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
# ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
# e.g.
# ARG MAVEN_MIRROR_URL=http://192.168.64.1:8081/nexus/content/groups/public

RUN mvn -DskipTests clean package -Pnative

FROM registry.fedoraproject.org/fedora-minimal

COPY --from=builder /project/target/helloworld-java-quarkus-1.0-SNAPSHOT-runner /app

ENTRYPOINT [ "/app" ]

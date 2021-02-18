ARG IMAGE=registry.access.redhat.com/ubi8/ubi-minimal


FROM ${IMAGE}

MAINTAINER Briezh Khenloo
### Required Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels#####
LABEL name="briezh/picapport" \
      vendor="aka BKhenloo" \
      maintainer="Briezh Khneloo" \
      summary="Picapport photo server" \
      description="Picapport | The private photo server" \
      run="docker run -rm -p 8080:80 -v <hostdir>:srv/photo -dt docker.io/briezh/picapport:latest"


EXPOSE 80


ARG JAVA=java-11-openjdk-headless

RUN microdnf install --nodocs ${JAVA} \
 && microdnf clean all \
 && mkdir -p /opt/picapport/.picapport \
 && printf "%s\n%s\n%s\n" "server.port=80" "robot.root.0.path=/srv/photo" "foto.jpg.usecache=2" > /opt/picapport/.picapport/picapport.properties 


WORKDIR /opt/picapport
ENV PICAPPORT_LANG=de \
    PICAPPORT_LOG=WARNING \
    XMS=256m \
    XMX=2048m


LABEL version="9.0.01"
ADD https://www.picapport.de/download/9-0-01/picapport-headless.jar /opt/picapport/picapport-headless.jar


ENTRYPOINT java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=/opt/picapport -jar picapport-headless.jar

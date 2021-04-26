ARG IMAGE=fedora:latest

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




RUN dnf install glibc-langpack-de langpacks-de -y
ENV LANG='de_DE.UTF-8' LANGUAGE='de_DE:de' LC_ALL='de_DE.UTF-8'


ARG JAVA=java-11-openjdk-headless

RUN dnf install --nodocs ${JAVA} \
 && dnf update; dnf clean all
RUN mkdir -p /opt/picapport/.picapport \
 && printf "%s\n%s\n%s\n" "server.port=80" "robot.root.0.path=/srv/photo" "foto.jpg.usecache=2" > /opt/picapport/.picapport/picapport.properties 


WORKDIR /opt/picapport
ENV PICAPPORT_LANG=de \
    PICAPPORT_LOG=WARNING \
    XMS=256m \
    XMX=2048m

ARG VERSION=9-1-07
LABEL version="${VERSION}"
ADD https://www.picapport.de/download/${VERSION}/picapport-headless.jar /opt/picapport/picapport-headless.jar


ENTRYPOINT java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=/opt/picapport -jar picapport-headless.jar

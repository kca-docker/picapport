ARG IMAGE=fedora:latest
ARG VERSION=9-0-01
ARG PORT=80


FROM ${IMAGE}

ENV PICAPPORT_PORT=${PORT}
ENV PICAPPORT_LANG=de
ENV PICAPPORT_LOG=WARNING
ENV XMS=256m
ENV XMX=2048m

RUN dnf --setopt=install_weak_deps=False --best install -y java && echo "$(java -version)" && dnf clean all \
 && mkdir -p /opt/picapport/.picapport \
 && printf ""%s\n%s\n%s\n" "server.port=${PICAPPORT_PORT}" "robot.root.0.path=/srv/photo" "foto.jpg.usecache=2" > /opt/picapport/.picapport/picapport.properties"

ADD https://www.picapport.de/download/${VERSION}/picapport-headless.jar /opt/picapport/picapport-headless.jar

ENTRYPOINT java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=/opt/picapport -jar picapport-headless.jar

WORKDIR /opt/picapport
EXPOSE ${PICAPPORT_PORT}

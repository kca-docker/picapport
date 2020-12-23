ARG IMAGE=fedora:latest


FROM ${IMAGE}

ARG VERSION=9-0-01
ARG PORT=80
ARG FOLDER=/opt/picapport
ARG SUBFOLDER_CFG=/.picapport
ARG CFG=picapport.properties

ENV PICAPPORT_PORT=${PORT}
ENV PICAPPORT_LANG=de
ENV PICAPPORT_LOG=WARNING
ENV PICAPPORT_PIC=/srv/photo
ENV XMS=256m
ENV XMX=2048m

RUN dnf --setopt=install_weak_deps=False --best install -y java && echo "$(java -version)" && dnf clean all \
 && mkdir -p ${FOLDER}${SUBFOLDER_CFG} \
 && printf "%s\n%s\n%s\n" "server.port=${PICAPPORT_PORT}" "robot.root.0.path=${PICAPPORT_PIC}" "foto.jpg.usecache=2" > ${FOLDER}${SUBFOLDER_CFG}/picapport.properties

ADD https://www.picapport.de/download/${VERSION}/picapport-headless.jar ${FOLDER}/picapport-headless.jar

WORKDIR ${FOLDER}
EXPOSE ${PICAPPORT_PORT}

ENTRYPOINT /bin/bash -c java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=${FOLDER} -jar picapport-headless.jar

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
ENV XMS=256m
ENV XMX=2048m

RUN dnf --setopt=install_weak_deps=False --best install -y java && echo "$(java -version)" && dnf clean all \
 && mkdir -p ${FOLDER}${SUBFOLDER_CFG} \
 && printf "%s\n%s\n%s\n" "server.port=${PICAPPORT_PORT}" "robot.root.0.path=/srv/photo" "foto.jpg.usecache=2" > ${FOLDER}${SUBFOLDER_CFG}/picapport.properties

ADD https://www.picapport.de/download/${VERSION}/picapport-headless.jar /opt/picapport/picapport-headless.jar

WORKDIR /opt/picapport
EXPOSE ${PICAPPORT_PORT}

ENTRYPOINT ["java"]
CMD ["-Xms$XMS", "-Xmx$XMX", "-DTRACE=$PICAPPORT_LOG", "-Duser.language=$PICAPPORT_LANG", "-Duser.home=/opt/picapport", "-jar picapport-headless.jar"]

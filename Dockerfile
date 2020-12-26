ARG IMAGE=registry.access.redhat.com/ubi8/ubi-minimal


FROM ${IMAGE}

ARG PORT=80
ARG VERSION=9-0-01
ARG FOLDER=/opt/picapport
ARG CFGFOLDER=/.picapport
ARG CFGFILE=picapport.properties
ARG PICAPPORT_PIC=/srv/photo
ARG PICAPPORT_PORT=${PORT}

RUN microdnf install java-1.8.0-openjdk-headless \
 &&	microdnf clean all \
 && echo "$(java -version)" \
 && mkdir -p ${FOLDER}${CFGFOLDER} \
 && printf "%s\n%s\n%s\n" "server.port=${PICAPPORT_PORT}" "robot.root.0.path=${PICAPPORT_PIC}" "foto.jpg.usecache=2" > ${FOLDER}${CFGFOLDER}/${CFGFILE}

ADD https://www.picapport.de/download/${VERSION}/picapport-headless.jar ${FOLDER}/picapport-headless.jar

WORKDIR ${FOLDER}
EXPOSE ${PICAPPORT_PORT}

ENV PICAPPORT_LANG=de \
    PICAPPORT_LOG=WARNING \
    XMS=256m \
    XMX=2048m

ENTRYPOINT java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=${FOLDER} -jar picapport-headless.jar
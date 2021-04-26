ARG IMAGE=fedora:latest


FROM ${IMAGE}

MAINTAINER Briezh Khenloo
##	Required Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="briezh/picapport" \
	vendor="aka BKhenloo" \
	maintainer="Briezh Khneloo" \
	summary="Picapport photo server" \
	description="Picapport | The private photo server" \
	run="docker run -rm -p 8080:80 -v <hostdir>:srv/photo -dt docker.io/briezh/picapport:latest"

#RUN dnf install glibc-langpack-de langpacks-de -y

ARG VERSION=9-1-07
ARG PORT=80
ARG FOLDER_SRC=/srv/photo
ARG FOLDER_APP=/opt/picapport
ARG SUBFOLDER_CFG=/.picapport
ARG FILE_CFG=picapport.properties

ENV PICAPPORT_PORT=${PORT}
ENV PICAPPORT_LANG=de
ENV PICAPPORT_LOG=WARNING
ENV PICAPPORT_PIC=${FOLDER_SRC}
ENV XMS=256m
ENV XMX=2048m
ENV TZ=CET
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8



RUN dnf --nodocs --setopt=install_weak_deps=False --best install -y java && echo "$(java -version)" && dnf clean all \
 && mkdir -p ${FOLDER}${SUBFOLDER_CFG} \
 && printf "%s\n%s\n%s\n" "server.port=${PICAPPORT_PORT}" "robot.root.0.path=${PICAPPORT_PIC}" "foto.jpg.usecache=2" > ${FOLDER}${SUBFOLDER_CFG}/${FILE_CFG}

ADD https://www.picapport.de/download/${VERSION}/picapport-headless.jar ${FOLDER}/picapport-headless.jar

EXPOSE ${PICAPPORT_PORT}
WORKDIR ${FOLDER}

ENTRYPOINT java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=${FOLDER} -jar picapport-headless.jar

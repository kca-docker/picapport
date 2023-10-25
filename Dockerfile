ARG IMGNAME=debian
ARG IMGVERS=stable-slim

ARG VERSION=10-4-00
ARG OPENJDK=openjdk-17-jre

ARG PORT=80



##
FROM ${IMGNAME}:${IMGVERS} AS SRC

#ARGS
ARG WDIR=/picapport/.picapport
ARG VERSION
ARG PORT

# Create application base folder and configuration file
RUN mkdir -p $WDIR && \
    printf "%s\n%s\n%s\n" 'server.port=$PORT' 'robot.root.0.path=/srv/photos' 'foto.jpg.usecache=2' > ${WDIR}/picapport.properties

#Get application
ADD ./picapport-headless-${VERSION}.jar /picapport/picapport-headless.jar




##
FROM ${IMGNAME}:${IMGVERS}

ARG IMGNAME
ARG IMGVERS
ARG PORT
ARG VERSION
ARG OPENJDK

# Define environment
ENV PICAPPORT_LANG=de \
    PICAPPORT_PORT=$PORT \
    DTRACE=INFO \
    XMS=512m \
    XMX=2048m

# Set labels
LABEL name="bksolutions/picapport" \
      vendor="BKSolutions" \
      summary="Photo gallery" \
      description="PicApport self-hosted private photo server with photo gallery and photo management." \
      version=${VERSION} \
      openjdk=${OPENJDK} \
      release=1 \
      bksolutions.docker.picapport.ci-build=woodpecker \
      bksolutions.docker.picapport.ci-build.source=https://github.com/kca-docker/picapport \
      bksolutions.docker.picapport.run="docker run -rm --name picapport -p 8080:80 -v <$PWD>/photo:srv/photo -dt docker.io/bksolutions/picapport:latest" \
      bksolutions.docker.picapport.docker.cmd="docker run -d -p 8080:80 bksolutions/picapport:latest" \
      bksolutions.docker.picapport.podman.cmd="podman run -d -p 8080:80 bksolutions/picapport:latest" \
      org.opencontainers.image.version=${VERSION}
##Set by woodpecker-ci buildx
#      org.opencontainers.image.created=
#      org.opencontainers.image.source=<github>
#      org.opencontainers.image.url=<github>
#      org.opencontainers.image.revision=

COPY --from=SRC /picapport /opt/picapport

WORKDIR /opt/picapport
EXPOSE ${PICAPPORT_PORT}

#RUN apk add --no-cache tini $OPENJDK
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt -y install tini ${OPENJDK} \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT tini -- java -Xms$XMS -Xmx$XMX -DTRACE=$DTRACE \
    -Duser.home=/opt/picapport \
    -Duser.language=$PICAPPORT_LANG \
    -jar picapport-headless.jar
ARG IMGNAME=debian
ARG IMGVERS=stable-slim

ARG VERSION=10-4-00
ARG RELEASE=picapport-headless
ARG OPENJDK=openjdk-17-jre

ARG PORT=80

##
FROM ${IMGNAME}:${IMGVERS} AS SRC

#ARGS
ARG WDIR=/picapport/.picapport
ARG VERSION
ARG RELEASE
ARG PORT

# Create application base folder and configuration file
# Behoben (SC2016): Doppelte statt einfache Anführungszeichen, damit Variablen expandieren können
RUN mkdir -p "$WDIR" && \
    printf "%s\n%s\n%s\n" "server.port=$PORT" "robot.root.0.path=/srv/photos" "foto.jpg.usecache=2" > "${WDIR}/picapport.properties"

# Get application
# Behoben (DL3020 - Error): COPY statt ADD für lokale .jar-Dateien verwenden
COPY ./${RELEASE}-${VERSION}.jar /picapport/${RELEASE}.jar

##
FROM ${IMGNAME}:${IMGVERS}

ARG IMGNAME
ARG IMGVERS
ARG PORT
ARG VERSION
ARG RELEASE
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
      bksolutions.docker.picapport.ci-build="github-actions" \
      bksolutions.docker.picapport.ci-build.source="https://github.com" \
      bksolutions.docker.picapport.run="docker run -rm --name picapport -p 8080:80 -v ./photo:srv/photo -dt docker.io/bksolutions/picapport" \
      bksolutions.docker.picapport.docker.cmd="docker run -d -p 8080:80 bksolutions/picapport" \
      bksolutions.docker.picapport.podman.cmd="podman run -d -p 8080:80 bksolutions/picapport" \
      org.opencontainers.image.version=${VERSION} \
      org.opencontainers.image.release=${RELEASE}

COPY --from=SRC /picapport /opt/picapport

WORKDIR /opt/picapport
EXPOSE ${PICAPPORT_PORT}

# Behoben (DL3008): Da openjdk via ARG flexibel übergeben wird, ignorieren wir das Version-Pinning gezielt für diese Zeile
# hadolint ignore=DL3008
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests tini ${OPENJDK} && \
    rm -rf /var/lib/apt/lists/*

# Behoben (DL3025): ENTRYPOINT in gültige JSON-Array-Notation überführt
ENTRYPOINT ["tini", "--", "java", "-Xms512m", "-Xmx2048m", "-DTRACE=INFO", "-Duser.home=/opt/picapport", "-Duser.language=de", "-jar", "picapport-headless.jar"]

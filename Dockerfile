# Offizielles, minimales Java-Runtime-Image auf Alpine-Basis
ARG IMGNAME=eclipse-temurin
ARG IMGVERS=21-jre-alpine

ARG VERSION=10-4-00
ARG RELEASE=picapport-headless
ARG PORT=80


## STAGE 1: Konfiguration und App vorbereiten (Multi-Stage)
# FROM ${IMGNAME}:${IMGVERS} AS SRC

# ARG WDIR=/picapport/.picapport
# ARG PORT
# ARG VERSION
# ARG RELEASE

# RUN mkdir -p "$WDIR" && \
#     printf "%s\n%s\n%s\n" "server.port=$PORT" "robot.root.0.path=/srv/photos" "foto.jpg.usecache=2" > "${WDIR}/picapport.properties"

# COPY ./${RELEASE}-${VERSION}.jar /picapport/${RELEASE}.jar


## STAGE X: Das finale, schlanke Produktions-Image
FROM ${IMGNAME}:${IMGVERS}

ARG WDIR=/opt/picapport
ARG CDIR=/opt/picapport/.picapport

ARG VERSION
ARG RELEASE
ARG PORT

ENV PICAPPORT_LANG=de \
    PICAPPORT_PORT=$PORT \
    DTRACE=INFO \
    XMS=512m \
    XMX=2048m

LABEL name="bksolutions/picapport" \
      vendor="BKSolutions" \
      summary="Photo gallery" \
      description="PicApport self-hosted private photo server with photo gallery and photo management." \
      version=${VERSION}\
      openjdk=${IMGVERS} \
      bksolutions.docker.picapport.ci-build="github-actions" \
      bksolutions.docker.picapport.ci-build.source="https://github.com" \
      bksolutions.docker.picapport.run="docker run -rm --name picapport -p 8080:80 -v ./photo:srv/photo -dt docker.io/bksolutions/picapport" \
      bksolutions.docker.picapport.docker.cmd="docker run -d -p 8080:80 bksolutions/picapport" \
      bksolutions.docker.picapport.podman.cmd="podman run -d -p 8080:80 bksolutions/picapport" \
      bksolutions.docker.picapport.healthcheck="wget -q -O - http://localhost:${PICAPPORT_PORT}/ > /dev/null || exit 1" \
      org.opencontainers.image.version=${VERSION} \
      org.opencontainers.image.release=${RELEASE}


RUN mkdir -p "$CDIR" && \
    printf "%s\n%s\n%s\n" "server.port=$PORT" "robot.root.0.path=/srv/photos" "foto.jpg.usecache=2" > "${CDIR}/picapport.properties"

#COPY --from=SRC /picapport /opt/picapport
COPY ./${RELEASE}-${VERSION}.jar /opt/picapport/${RELEASE}.jar

WORKDIR ${WDIR}
EXPOSE ${PICAPPORT_PORT}

# Installiert Tini (Init-Prozess) sowie Grafikbibliotheken für stabile Bildverarbeitung.
# wget ist in Alpine bereits integriert und muss nicht installiert werden!
RUN apk add --no-cache tini fontconfig ttf-dejavu

# DOCKER HEALTHCHECK (Kombinations-Liste / JSON-Array mit Shell-Aktivierung)
# hadolint ignore=DL3056,SC2015
HEALTHCHECK --interval=60s --timeout=5s --start-period=45s --retries=3 \
  CMD ["/bin/sh", "-c", "wget -q -O - http://localhost:${PICAPPORT_PORT}/ > /dev/null || exit 1"]

ENTRYPOINT ["tini", "--", "java", "-Xms${XMS}", "-Xmx${XMX}", "-XX:MaxRAMPercentage=75.0", "-DTRACE=${DTRACE}", "-Duser.home=${WDIR_PATH}", "-Duser.language=de", "-jar", "${RELEASE_FILE}"]
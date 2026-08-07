# Offizielles, minimales Java-Runtime-Image auf Alpine-Basis
ARG IMGNAME=eclipse-temurin
ARG IMGVERS=21-jre-alpine

# Globale Standardwerte (Build-Args)
ARG VERSION=10-4-00
ARG RELEASE=picapport-headless
ARG PORT=80

## STAGE X: Das finale, schlanke Produktions-Image
FROM ${IMGNAME}:${IMGVERS}

# Re-Deklaration der globalen ARGs für diese Stage
ARG IMGVERS
ARG VERSION
ARG RELEASE
ARG PORT

ARG WDIR=/opt/picapport
ARG CDIR=/opt/picapport/.picapport

# ENV-Variablen für die Laufzeit (Runtime)
ENV PICAPPORT_LANG=de \
    PICAPPORT_PORT=$PORT \
    PICAPPORT_PATH=${WDIR} \
    RELEASE_FILE=${RELEASE}.jar \
    DTRACE=INFO \
    XMS=512m \
    XMX=2048m \
    XRAM=75.0 

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

# Installiert Tini und Grafikbibliotheken direkt am Anfang (besseres Caching)
RUN apk add --no-cache tini fontconfig ttf-dejavu

# Konfiguration erstellen (Nutzt jetzt die ENV-Variable für Konsistenz)
RUN mkdir -p "$CDIR" && \
    printf "%s\n%s\n%s\n" "server.port=${PICAPPORT_PORT}" "robot.root.0.path=/srv/photos" "foto.jpg.usecache=2" > "${CDIR}/picapport.properties"

# JAR-Datei kopieren
COPY ./${RELEASE}-${VERSION}.jar ${WDIR}/${RELEASE}.jar

WORKDIR ${PICAPPORT_PATH}
EXPOSE ${PICAPPORT_PORT}

# DOCKER HEALTHCHECK
HEALTHCHECK --interval=60s --timeout=5s --start-period=45s --retries=3 \
  CMD ["/bin/sh", "-c", "wget -q -O - http://localhost:${PICAPPORT_PORT}/ > /dev/null || exit 1"]

# KORREKTUR: Exec-Form mit expliziter Shell-Aktivierung, damit ENV-Variablen aufgelöst werden!
ENTRYPOINT ["tini", "--", "/bin/sh", "-c", "java -Xms${XMS} -Xmx${XMX} -XX:MaxRAMPercentage=${XRAM} -DTRACE=${DTRACE} -Duser.home=${PICAPPORT_PATH} -Duser.language=${PICAPPORT_LANG} -jar ${PICAPPORT_PATH}/${RELEASE_FILE}"]

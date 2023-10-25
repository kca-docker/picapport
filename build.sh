#!/usr/bin/env sh

set -euxo pipefail

VersQEMU=$(head -n 1 qemu.vers)
Project="picapport"

while read -r vers
do
    echo "Version from file= ${vers}"
    VersMajor=$(echo ${vers} | sed -En "s/(.*)-(.*)-([[:digit:]]*).*/\1/p")
    VersMinor=$(echo ${vers} | sed -En "s/(.*)-(.*)-([[:digit:]]*).*/\2/p")
    VersPatch=$(echo ${vers} | sed -En "s/(.*)-(.*)-([[:digit:]]*).*/\3/p")
    echo "Version= ${VersMajor}.${VersMinor}.${VersPatch}"

    IMAGE_NAME="${Project}"
    IMAGE_TAG="${VersMajor}.${VersMinor}.${VersPatch}-${OPENJDK}"
    echo "Name:Tag= ${IMAGE_NAME}:${IMAGE_TAG}"

    FQ_IMAGE_NAME="${CI_REGISTRY_IMAGE}:${IMAGE_TAG}"
    echo "FQIN= ${FQ_IMAGE_NAME}"

    buildah bud --build-arg QEMU=x86_64 --build-arg OPENJDK=${OPENJDK} --build-arg QEMU_VERSION=${VersQEMU} --build-arg VERSION=${VersMajor}-${VersMinor}-${VersPatch} -f ./Dockerfile -t ${FQ_IMAGE_NAME} .

    buildah push ${FQ_IMAGE_NAME}

    buildah push ${FQ_IMAGE_NAME} ${CI_REGISTRY_PATH_DOCKERHUB}/${IMAGE_NAME}:${VersMajor}.${VersMinor}.${VersPatch}-${OPENJDK}

    if [[ "${latest}" == "true" ]]; then 
        buildah push ${FQ_IMAGE_NAME} ${CI_REGISTRY_PATH_DOCKERHUB}/${IMAGE_NAME}:${VersMajor}.${VersMinor}.${VersPatch}
        buildah push ${FQ_IMAGE_NAME} ${CI_REGISTRY_PATH_DOCKERHUB}/${IMAGE_NAME}:latest
        latest="done"
    fi

done < "picapport.vers"

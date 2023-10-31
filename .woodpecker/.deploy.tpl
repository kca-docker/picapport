---

variables:
  - &file Dockerfile
  - &dhub https://index.docker.io/v1/
  - &arch linux/amd64,linux/i386,linux/arm/v7,linux/arm64/v8
  - &repo bksolutions/picapport
  - &branch release


steps:
  download-data:
    group: prepare
    image: alpine/curl
    commands:
      - curl https://www.picapport.de/download/<VERSION>/picapport-headless.jar --output ./picapport-headless-<VERSION>.jar
    when:
      branch: *branch


  build:
    image: woodpeckerci/plugin-docker-buildx
    group: build
    settings:
      dockerfile: *file
      platforms: *arch
      dry_run: false
      repo: *repo
      tags:
        - '<VERSION>'
      registry: *dhub
      logins:
        - registry: *dhub
          username:
            from_secret: DOCKER_BKSOL_USER
          password:
            from_secret: DOCKER_BKSOL_PASS
    when:
      branch: *branch
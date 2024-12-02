---

variables:
  - &file Dockerfile
  - &dhub https://index.docker.io/v1/
  - &arch linux/amd64,linux/i386,linux/arm/v7,linux/arm64/v8
  - &repo bksolutions/picapport
  - &branch release


steps:
  download-app:
    when: 
      - event: [push, deployment, cron, manual]
        branch: *branch
    image: alpine/curl
    commands:
      - curl https://www.picapport.de/download/<VERSION>/picapport-headless.jar --output ./picapport-headless-<VERSION>.jar


  build:
    when:
      - event: [push, deployment, cron, manual]
        branch: *branch
    image: woodpeckerci/plugin-docker-buildx
    depends_on: [download-app]                        #Build and push, after app download done
    settings:
      dockerfile: *file
      build_args:
        - VERSION=<VERSION>
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

# Picapport  <!-- omit in toc -->

[Picapport](https://www.picapport.de/de/index.php) - The private photo server

# Content  <!-- omit in toc -->

- [Getting Started](#getting-started)
  - [Prerequisities](#prerequisities)
  - [Usage](#usage)
    - [Container Parameters](#container-parameters)
    - [Environment Variables](#environment-variables)
    - [Volumes](#volumes)
    - [Useful Files and Locations](#useful-files-and-locations)
  - [Using Podman instead of Docker](#using-podman-instead-of-docker)
  - [Compose File(s)](#compose-files)
    - [Docker](#docker)
    - [Podman](#podman)
- [Find Us](#find-us)
- [Versioning](#versioning)
- [Authors](#authors)


# Getting Started

These instructions will cover usage information and for the docker container 

## Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

## Usage

### Container Parameters

The image could be started by the following command.  

```shell
$ docker run -d bksolutions/picapport
or
$ docker run -d bksolutions/picapport:latest
```

### Environment Variables

* `PICAPPORT_LANG` - Set default language; default=de
* `PICAPPORT_LOG` - Set default logging level, default=WARNING
* `XMS` - Set ...
* `XMX` - Set ...

### Volumes

* `/opt/picapport` - Picapport working directory.
* `/opt/picapport/.picapport` - Picapport configuration folder.

### Useful Files and Locations

* `/opt/picapport/.picapport/picapport.properties` - Picapport configuration file. See also https://wiki.picapport.de/display/PIC/PicApport-Server+Guide
* `/etc/locale.conf` - Locale setting, could be changed to LANG="de_DE.UTF-8" to support german e.g.: ä, ö, ü See also https://wiki.picapport.de/pages/viewpage.action?pageId=2261139

See [config](https://wiki.picapport.de/display/PIC/PicApport-Server+Guide) for further information.

## Using Podman instead of Docker

If using `podman` Version >=1.9 instead of `docker` it should be possible to use the `auto-update` feature with `systemd`.

First create the container (pod) than run `generate` command. The systemd service files will be created within the same folder.
These .service file(s) should be moved to a systemd folder. 
If the system uses SELinux the new files must be updated with the correct labels. 
Then the systemd daemon must reload the service files.

```shell
$ podman create --name <container_name> \
 -p [host]:8080 \
 -v [host]:/opt/picapport:Z \
 -l "io.containers.autoupdate=registry" \
 -t bksolutions/picapport:latest

$ podman generate systemd --new --name <container_name> --files
$ mv *.service /usr/lib/systemd/
$ restorecon -Rv /usr/lib/systemd/
$ systemctl daemon-reload

$ systemctl start <service> --now
```

See [docs.podman.io](http://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html) for further information.

## Compose File(s)

### Docker

```yaml
version: "3"
services:
  picapport:
    container_name: picapport
    image: docker.io/bksolutions/picapport:latest
    restart: unless-stopped
    environment:
      - Xms=512m
      - Xmx=1024m
      - PICAPPORT_LANG=de
    volumes:
      - ${PWD}/pic.conf.d:/opt/picapport/.picapport:rw
      - ${PWD}/photo.d:/srv/photos:ro
```

### Podman

```yaml
version: "3"
services:
  picapport:
    container_name: picapport
    image: docker.io/bksolutions/picapport:latest
    restart: unless-stopped
    environment:
      - Xms=512m
      - Xmx=1024m
      - PICAPPORT_LANG=de
    volumes:
      - ${PWD}/pic.conf.d:/opt/picapport/.picapport:Z
      - ${PWD}/photo.d:/srv/photos:ro
    labels:
      - "io.containers.autoupdate=registry"
```

# Find Us

* [GitHub](https://github.com/kca-docker/picapport)

# Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the 
[tags on this repository](https://github.com/kca-docker/picapport/tags). 

# Authors

* **Carsten Kruse** - *update* - [C. Kruse](https://github.com/KruseCarsten)

See also the list of [contributors](https://github.com/kca-docker/picapport/contributors) who 
participated in this project.

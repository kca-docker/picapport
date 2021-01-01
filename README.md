# Picapport

[Picapport](https://www.picapport.de/de/index.php) - The private photo server

## Getting Started

These instructions will cover usage information and for the docker container 

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Container Parameters

The image could be started by the following command.  

```shell
$ docker run -d briezh/picapport
```

There are two images available with a different base image
* `latest` - ubi8-minimal
* `fedora` - fedora (stable)

```shell
$ docker run -d briezh/picapport:latest
or
$ docker run -d briezh/picapport:fedora
```

#### Environment Variables

* `PICAPPORT_LANG` - Set default language; default=de
* `PICAPPORT_LOG` - Set default logging level, default=WARNING
* `XMS` - Set ...
* `XMX` - Set ...

#### Volumes

* `/opt/picapport` - Picapport working directory.
* `/opt/picapport/.picapport` - Picapport configuration folder.

#### Useful File Locations

* `/opt/picapport/.picapport/picapport.properties` - Picapport configuration file.

See [config](https://wiki.picapport.de/display/PIC/PicApport-Server+Guide) for further information.

### Useing Podman instead of Docker

If using `podman` Version >=1.9 instead of `docker` it should be possible to use the `auto-update` feature with `systemd`.

First create the container (pod) than run `generate` command. The systemd service files will be created within the same folder.
These .service file(s) should be moved to a systemd folder. 
If the system uses SELinux the new files must be updated with the correct labels. 
Then the systemd daemon must reload the service files.

```shell
$ podman create --name <container_name> \
 -p [host]:8080 \
 -v [host]:/opt/picapport:Z \
 -l "io.containers.autoupdate=image" \
 -dt briezh/picapport:latest

$ podman generate systemd --new --name <container_name> --files
$ mv *.service /usr/lib/systemd/
$ restorecon -Rv /usr/lib/systemd/
$ systemctl daemon-reload
```

## Find Us

* [GitHub](https://github.com/BKhenloo/holdingnuts_server)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the 
[tags on this repository](https://github.com/BKhenloo/holdingnuts_server/tags). 

## Authors

* **Briezh Khenloo** - *Initial work* - [B.Khenloo](https://github.com/BKhenloo)

See also the list of [contributors](https://github.com/BKhenloo/holdingnuts_server/contributors) who 
participated in this project.

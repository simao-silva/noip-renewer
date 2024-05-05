# noip-renewer

![GitHub last commit](https://img.shields.io/github/last-commit/simao-silva/noip-renewer?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/simao-silva/noip-renewer?style=for-the-badge)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/simao-silva/noip-renewer/docker-build-alpine.yml?label=Alpine%20build&style=for-the-badge)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/simao-silva/noip-renewer/docker-build-debian.yml?label=Debian%20build&style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/simaofsilva/noip-renewer?style=for-the-badge)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/simaofsilva/noip-renewer/alpine?label=Alpine%20image%20size&style=for-the-badge)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/simaofsilva/noip-renewer/debian?label=Debian%20image%20size&style=for-the-badge)
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen.svg?style=for-the-badge)](https://renovatebot.com)

:uk:: Renewing No-IP hosts by browser automation. Renews all hosts available for confirmation, without any user interaction with a browser. <br/>
:portugal:: Renovação de <i>hosts</i> No-IP recorrendo a automatização do navegador. Renova todos os <i>hosts</i> disponíveis para confirmação sem ser necessário interação do utilizador com um navegador.

#### Requirements
- [Docker](https://www.docker.com/)

## Obtaining image

#### Pulling image from [Docker Hub](https://hub.docker.com/r/simaofsilva/noip-renewer/tags) 

```shell script
# Debian
docker pull simaofsilva/noip-renewer:debian

# Alpine
docker pull simaofsilva/noip-renewer:alpine
# or
docker pull simaofsilva/noip-renewer:latest
```

#### Building image locally

```sh
docker build -t simaofsilva/noip-renewer -f Dockerfile.dev .
```

## Using image

```sh
docker run --rm -it simaofsilva/noip-renewer:<TAG>
```
or
```sh
docker run --rm -it simaofsilva/noip-renewer:<TAG> <EMAIL> <PASSWORD>
```
or
```sh
docker run --rm --env NO_IP_USERNAME=<EMAIL> --env NO_IP_PASSWORD=<PASSWORD> simaofsilva/noip-renewer:<TAG> 
```
or with 2FA
```sh
docker run --rm --env NO_IP_USERNAME=<EMAIL> --env NO_IP_PASSWORD=<PASSWORD> --env NO_IP_TOTP_KEY=<NOIP TOTP KEY> simaofsilva/noip-renewer:<TAG> 
```

or with translation disabled
```sh
docker run --rm --env NO_IP_USERNAME=<EMAIL> --env NO_IP_PASSWORD=<PASSWORD> --env TRANSLATE_ENABLED=false simaofsilva/noip-renewer:<TAG> 
```

## Known issues / limitations
* The script assumes that the No-IP account language is set to English. For other languages it depends on the translation provided by [googletrans](https://pypi.org/project/googletrans/) so it might not work in other languages ([#11](https://github.com/simao-silva/noip-renewer/issues/11)). In any case, translation can be disabled by setting `TRANSLATE_ENABLED` to `false`; 

* In fresh accounts an extra pop up might appear that unable the script to proceed ([#14](https://github.com/simao-silva/noip-renewer/issues/14)). It appears to not show on following renovations.

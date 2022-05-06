# noip-renewer

![GitHub last commit](https://img.shields.io/github/last-commit/simao-silva/noip-renewer?style=for-the-badge)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/simao-silva/noip-renewer/build%20and%20push%20image?style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/simaofsilva/noip-renewer?style=for-the-badge)
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen.svg?style=for-the-badge)](https://renovatebot.com)

:uk:: Renewing No-IP hosts by browser automation. Renews all hosts available for confirmation, without any user interaction with a browser. <br/>
:portugal:: Renovação de <i>hosts</i> No-IP recorrendo a automatização do navegador. Renova todos os <i>hosts</i> disponíveis para confirmação sem ser necessário interação do utilizador com um navegador.

#### Requirements
- [Docker](https://www.docker.com/)

## Obtaining image

#### Pulling image from [Docker Hub](https://hub.docker.com/r/simaofsilva/noip-renewer/tags) 
```shell script
# armhf/armv7l
docker pull simaofsilva/noip-renewer:debian

# x86_64 or aarch64/arm64
docker pull simaofsilva/noip-renewer:latest
```

#### Building image locally
```shell script
docker build -t simaofsilva/noip-renewer .
```

## Using image
```shell script
docker run --rm -it simaofsilva/noip-renewer:<TAG>
```
or
```shell script
docker run --rm -it simaofsilva/noip-renewer:<TAG> <EMAIL> <PASSWORD>
```


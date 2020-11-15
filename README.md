# noip-renewer
[EN]: Renewing No-IP hosts by browser automation. Renews all hosts available for confirmation, without any user interaction with a browser. <br/>
[PT]: Renovação de <i>hosts</i> No-IP recorrendo a automatização do navegador. Renova todos os <i>hosts</i> disponíveis para confirmação sem ser necessário interação do utilizador com um navegador.

#### Requirements
- [Docker](https://www.docker.com/)

## Obtain image

#### Pulling image from [Docker Hub](https://hub.docker.com/r/simaofsilva/noip-renewer) 
```shell script
docker pull simaofsilva/noip-renewer
```

#### Building image locally
```shell script
docker build -t simaofsilva/noip-renewer .
```

## Using image
```shell script
docker run --rm -it simaofsilva/noip-renewer
```

or

```shell script
docker run --rm -it simaofsilva/noip-renewer <EMAIL> <PASSWORD>
```

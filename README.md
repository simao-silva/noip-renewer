# noip-renewer
[EN]: Renewing No-IP hosts by browser automation. Renews all hosts available for confirmation, without any user interaction with a browser. <br/>
[PT]: Renovar No-IP <i>hosts</i> recorrendo a automatização do navegador. Renova todos os <i>hosts</i> disponíveis para confirmação sem ser necessário interação do utilizador com um navegador.

#### Requirements
- [Docker](https://www.docker.com/)

### Usage

- Create image

```bash
docker build -t noip .
```

- Run image

```bash
docker run -it noip
```

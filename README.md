# pulse-agent-docker
Docker build of Pulse Docker Agent based on Alpine Linux.

This image differs from official image by having built-in support for docker secrets, and being somewhat smaller.

For more information, read on [here](https://github.com/rcourtman/Pulse/blob/main/docs/DOCKER_MONITORING.md).

This project, including bundled software is licensed under MIT license. See: [LICENSE](LICENSE).


#### Docker build


##### Images
```
ghcr.io/n0rthernl1ghts/pulse-agent:latest
ghcr.io/n0rthernl1ghts/pulse-agent:4.24.0
```

Image is tagged with the Pulse Agent software version.

##### Supported platforms
- linux/amd64
- linux/arm64

##### Running
To run the pulse agent, you can use the following command. Note that you need to provide a `pulse_token` secret and configure the agent through environment variables.<br/>
Due to design, secrets and environment variables are interchangeable, meaning you can use `PULSE_TOKEN` as environment variable. This is discouraged, however. 

```yaml
secrets:
  pulse_token:
    file: secrets/pulse_token.txt

networks:
  default:

services:
  agent:
    init: true
    image: ghcr.io/n0rthernl1ghts/pulse-agent:latest
    pull_policy: always
    environment:
      PULSE_URL: https://my-pulse.example.com
    secrets:
      - pulse_token
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      default:
```
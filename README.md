# ILIAS Chat Server

Docker-ized version of the [**ILIAS Chat Server**](https://github.com/ILIAS-eLearning/ILIAS/blob/trunk/Modules/Chatroom/README.md).

> ILIAS provides several classes to create and send Emails/Messages for different purposes.

The ILIAS chat server is a Node.js server providing websocket connections for real-time chat in ILIAS LMS.

This Docker files / image aims to facilate setting up the chat server in an isolated environment, either as part of the docker(-compose) network on the same host as ILIAS, or distributed to another physical or virtual host.

* Code on [GitHub](https://github.com/uni-halle/ilias-chatserver-docker) ([Issues](https://github.com/uni-halle/ilias-chatserver-docker/issues))
* Image on [Docker Hub](https://hub.docker.com/r/unihalle/ilias-chatserver)
* Author: Dockerization: Abt. Anwendungssysteme, [ITZ Uni Halle](http://itz.uni-halle.de/); Image includes various open source software.
  See Dockerfile for details.
* Support: As a **university** or **research facility** you might be successful in requesting support through the **[ITZ Helpdesk](mailto:helpdesk@itz.uni-halle.de)** (this can take some time) or contacting the author directly. For **any other entity**, including **companies**, see [my home page](https://wohlpa.de/) for contact details and pricing. You may request hosting, support or customizations.
  *Reporting issues and creating pull requests is always welcome and appreciated.*

## Which version/ tag?

There are multiple versions/ tags available under [dockerhub:unihalle/ilias-chatserver/tags/](https://hub.docker.com/r/unihalle/ilias-chatserver/tags/). Please ensure the tag matches your ILIAS minor release's version number (MAJOR.MINOR.PATCH).

## Basic usage

Create the following file:

`.env` (adjust the values):
```
# IP-Address/FQN of Chat Server
ILIAS_CHAT_ADDRESS=chat

# Please enter a name for this ILIAS client.
# The entered string must be globally unique.
# Initially this value is set to the client
# id of the ILIAS client. If changed, the chat
# server must be restarted.
ILIAS_CHAT_CLIENT_NAME=ilias-main-client

# Please define unique strings used by ILIAS
# for authentication purposes when sending
# requests to the chat server.
ILIAS_CHAT_AUTH_KEY=authkey
ILIAS_CHAT_AUTH_SECRET=authsecret

# Database connection parameters as
# defined during setup and written in
# /path/to/ilias/[data_dir]/[client]/client.ini.php
ILIAS_CHAT_DB_HOST=mysql.example.com
ILIAS_CHAT_DB_PORT=3306
ILIAS_CHAT_DB_NAME=ilias
ILIAS_CHAT_DB_USER=ilias
ILIAS_CHAT_DB_PASS=very_secret
```

### Running using Docker only

```
docker run -d \
   --name TestIliasChatServer \
   --env-file .env \
   -p "27019:27019" \
   unihalle/ilias-chatserver
```

You can now test your chat server at http://host:27019/backend/Heartbeat/onscreen

### Running using docker-compose

Minimal example (binds port 27019 to localhost):

`docker-compose.yaml`:
```
version: "2"
services:
  chat:
    image: unihalle/ilias-chatserver:v5.3.12
    restart: always
    environment:
        - ILIAS_CHAT_ADDRESS
        - ILIAS_CHAT_CLIENT_NAME
        - ILIAS_CHAT_AUTH_KEY
        - ILIAS_CHAT_AUTH_SECRET
        - ILIAS_CHAT_DB_HOST
        - ILIAS_CHAT_DB_PORT
        - ILIAS_CHAT_DB_NAME
        - ILIAS_CHAT_DB_USER
        - ILIAS_CHAT_DB_PASS
    ports:
      - "127.0.0.1:27019:27019"
```

You can now test your chat server at http://127.0.0.1:27019/backend/Heartbeat/onscreen
Inside the docker-compose network, the URL is `http://chat:27019/backend/Heartbeat/onscreen`

### Using a proxy with HTTP basic auth and certificates

This is a complete example illustrating the use with a reverse proxy and encryption inside a network managed by docker-compose. Please replace `$VIRTUAL_HOST` with an actual host name.

```
# Copy https://raw.githubusercontent.com/uni-halle/ilias-chatserver-docker/develop/.env.example to your working directory and adjust the values or use the template above.

# Add certificates so they can be read by the reverse proxy
mkdir -p certs && cp VIRTUAL_HOST.crt certs/ && cp VIRTUAL_HOST.key certs/
```

`docker-compose.yaml`:
```
version: "2"
services:
  chat:
    image: unihalle/ilias-chatserver:v5.3.12
    build: .
    restart: always
    environment:
        - ILIAS_CHAT_ADDRESS
        - ILIAS_CHAT_CLIENT_NAME
        - ILIAS_CHAT_AUTH_KEY
        - ILIAS_CHAT_AUTH_SECRET
        - ILIAS_CHAT_DB_HOST
        - ILIAS_CHAT_DB_PORT
        - ILIAS_CHAT_DB_NAME
        - ILIAS_CHAT_DB_USER
        - ILIAS_CHAT_DB_PASS
    volumes:
        - "./volumes/logs:/var/log/chat"
        - "/etc/localtime:/etc/localtime:ro"
  reverse-proxy:
    image: jwilder/nginx-proxy:alpine
    environment:
        - DEFAULT_HOST=$VIRTUAL_HOST
    ports:
      - "443:443"
    restart: always
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./certs:/etc/nginx/certs:ro
```

Finally bring it up and watch the logs:
`docker-compose up -d && docker-compose logs -f`

You can now test your chat server at https://$VIRTUAL_HOST/backend/Heartbeat/onscreen if you have configured everything correctly.

Hit `Ctrl`+`C` to detach from container output (logs). The chat server's logs will be stored to `./volumes/logs/`.

To have more fine-grained control over the chat server's settings, override `/etc/chat/[client|server].cfg` in this container.


## Configuring ILIAS

Go to `Administration`→`Chat`

General Settings:

* Enable Chat: [x]
* Name: Same as you specified for ILIAS_CHAT_CLIENT_NAME
* Authentication: Same as you used for ILIAS_CHAT_AUTH_KEY and ILIAS_CHAT_AUTH_SECRET. You may use the pair generated by ILIAS.

Chatserver Settings:

* IP-Address/FQN of Chat Server: ILIAS_CHAT_ADDRESS; Note: You can override _client to chatserver_ and _ILIAS to chat server_ connection settings further down.
* Port of Chat Server: The port you have chosen for your chat server (e.g. as specified for the reverse proxy). Rarely used ports are often blocked by firewalls or proxy servers.
* Sub-Directory: Only if you configured something different than the supplied defaults
* Protocol: You may choose to let the Node.js server doing the HTTPS handling although I do not recommend that. Better use a reverse proxy. HTTPS through Node.js requires advanced configuration. You have to mount the certificate, key and dh-parameter into the ilias-chatserver container, as well as configuration (by default configuration is loaded from `/etc/chat/[client|server].cfg` in the container. Confer to [ILIAS//Modules/Chatroom/README.md](https://github.com/ILIAS-eLearning/ILIAS/blob/trunk/Modules/Chatroom/README.md) for how configuration should look like.
* Chatserver Log: If you do not use any custom configuration mounting, leave empty. Same for the error log.
* ILIAS to Server Connection: If your ILIAS runs in the same docker(-compose) network, you may wish your ILIAS PHP server to connect to http://[name-of-the-chatserver-container]:27019 - for the docker-compose example above, this would be http://chat:27019
* Client to Server Connection: If you run the chatserver behind a reverse proxy, the URL your ILIAS visitors can connect to should be specified here. It should really start with `https://` so their traffic is encrypted and private conversations stay private. For the above complete docker-compose example, this would be `https://$VIRTUAL_HOST`.
* Deletion of old Messages: Correspond to ILIAS_CHAT_DELETION_* variables. You may specify values here for consistency but if you do not mount the generated configuration files to the chat server container, they ain't going to change anything.


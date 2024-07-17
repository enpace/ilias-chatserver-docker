

FROM node:lts-alpine3.20
LABEL maintainer="O: University of Halle (Saale) Germany; OU: ITZ, department application systems" \
      license="Docker composition: MIT; Components: Please check"

ARG BUILD_NO
ARG TARGETARCH

ENV ILIAS_REPO="https://github.com/HochschuleLuzern/ILIAS-HSLU.git" \
    ILIAS_TAG_OR_BRANCH="release_8.7" \
    ILIAS_RUN_USER="ilias" \
    ILIAS_RUN_GROUP="ilias" \
    ILIAS_RUN_UID="800" \
    ILIAS_RUN_GID="800" \
    ILIAS_CHAT_HOME="/opt/chat" \
    ILIAS_CHAT_CONFIG_DIR="/etc/chat" \
    ILIAS_CHAT_LOG_DIR="/var/log/chat" \
    ILIAS_CHAT_PORT="27019" \
    GOSU_VERSION="1.17" \
    ARCH="arm64" \
    VERSION="8.7-9"


RUN apk add --no-cache \
      git gnupg \
      bash openssl curl tini \
    && set -ex \
    && for key in \
      B42F6819007F00F88E364FD4036A9C25BF357DD4 \
      ; do \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
      done \
    && set +x \
    && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}" \
    && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}.asc" \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && cd /tmp \
    && git clone \
      -b "${ILIAS_TAG_OR_BRANCH}" \
      --single-branch \
      --depth=1 \
      "${ILIAS_REPO}" \
    && mv ./ILIAS-HSLU ILIAS \
    && mv ./ILIAS/Modules/Chatroom/chat "${ILIAS_CHAT_HOME}" \
    && mv ./ILIAS/Modules/Chatroom/README.md "${ILIAS_CHAT_HOME}" \
    && rm -rf ./ILIAS \
    && addgroup -S -g "${ILIAS_RUN_GID}" "${ILIAS_RUN_GROUP}" \
    && adduser -S -D -H -G "${ILIAS_RUN_GROUP}" -h "${ILIAS_CHAT_HOME}" -u "${ILIAS_RUN_UID}" "${ILIAS_RUN_USER}" \
    && apk del git gnupg

ADD assets/* /

WORKDIR "${ILIAS_CHAT_HOME}"

VOLUME [ "${ILIAS_CHAT_CONFIG_DIR}", "${ILIAS_CHAT_LOG_DIR}" ]

EXPOSE "${ILIAS_CHAT_PORT}"

HEALTHCHECK --interval=7s --timeout=5s --start-period=15s CMD /docker-healthcheck.sh
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["app:serve"]


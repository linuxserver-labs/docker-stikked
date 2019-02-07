FROM lsiobase/alpine.nginx:3.8

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
    curl && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
   php7 \
   php7-ctype \
   php7-gd \
   php7-sqlite3 && \
 echo "**** install stikked ****" && \
 mkdir -p /app/stikked && \
 if [ -z ${stikked_RELEASE+x} ]; then \
	stikked_RELEASE=$(curl -sX GET "https://api.github.com/repos/claudehohl/stikked/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/stikked.tar.gz -L \
	"https://github.com/claudehohl/stikked/archive/${stikked_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/stikked.tar.gz -C \
	/app/stikked/ --strip-components=1 && \
 echo "**** cleanup ****" && \
 apk del --purge \
    build-dependencies && \
 rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config

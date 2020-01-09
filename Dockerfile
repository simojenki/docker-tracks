FROM ubuntu:18.04

MAINTAINER simojenki

ARG OVERLAY_VERSION="v1.22.1.0"
ENV TRACKS_VERSION="2.4.1"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y install \
        ruby \
        ruby-dev \
        git \
        build-essential \
        zlib1g-dev \
        liblzma-dev \
        sqlite3 \
        libsqlite3-dev \
        tzdata \
        sudo \
        yarn \
        nginx \
        curl && \
    gem update --system && \
    gem install \
        bundler

ADD https://github.com/TracksApp/tracks/archive/v${TRACKS_VERSION}.tar.gz /tmp

RUN cd /opt && \
    tar xfz /tmp/v${TRACKS_VERSION}.tar.gz && \
    ln -s "/opt/tracks-${TRACKS_VERSION}" /opt/tracks && \
    cd "/opt/tracks-${TRACKS_VERSION}" && \
    echo "gem: --no-rdoc --no-ri" > /root/.gemrc && \
    bundle config set jobs 4 && \
    bundle config set system 'true' && \
    bundle config set without 'development test mysql' && \
    bundle install && \
    rm -Rf "/opt/tracks-${TRACKS_VERSION}/log" && \
    ln -sf /data/log "/opt/tracks-${TRACKS_VERSION}/log" && \
    ln -sf /data/tmp "/opt/tracks-${TRACKS_VERSION}/tmp" && \
    ln -sf "/data/assets/${TRACKS_VERSION}" "/opt/tracks-${TRACKS_VERSION}/public/assets" && \
    rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/tracks /etc/nginx/sites-enabled/tracks

ADD https://github.com/just-containers/s6-overlay/releases/download/$OVERLAY_VERSION/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

ADD src/bin /opt/bin
ADD src/etc /etc
ADD src/config/database.sqlite3.yml /opt/tracks/config/database.sqlite3.yml

RUN rm /tmp/*

EXPOSE 3000/tcp

VOLUME /data
VOLUME /config

ENV RAILS_LOG_TO_STDOUT=true

ENTRYPOINT ["/init"]




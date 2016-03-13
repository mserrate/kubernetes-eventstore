FROM ubuntu:trusty
MAINTAINER mserrate

RUN apt-get update && apt-get install -y \
    tar \
    wget \
    curl \
    jq \
    # cleanup image
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
ENV UBUNTU_VERSION 14.04
ENV ES_VERSION 3.4.0
ENV EVENTSTORE_HOME /opt/EventStore
ENV EVENTSTORE_DB /data/db
ENV EVENTSTORE_LOG /data/logs

RUN wget -q http://download.geteventstore.com/binaries/EventStore-OSS-Ubuntu-${UBUNTU_VERSION}-v${ES_VERSION}.tar.gz -O /tmp/EventStore-OSS-Ubuntu-${UBUNTU_VERSION}-v${ES_VERSION}.tar.gz

RUN tar -xzf /tmp/EventStore-OSS-Ubuntu-${UBUNTU_VERSION}-v${ES_VERSION}.tar.gz -C /opt \
    && mv /opt/EventStore-OSS-Ubuntu-${UBUNTU_VERSION}-v${ES_VERSION} $EVENTSTORE_HOME \
    && mkdir -p $EVENTSTORE_DB $EVENTSTORE_LOG \
    #fix permissions for OpenShift
    && chmod -R a+rwx $EVENTSTORE_DB $EVENTSTORE_LOG
    
WORKDIR $EVENTSTORE_HOME

VOLUME $EVENTSTORE_DB
VOLUME $EVENTSTORE_LOG

COPY start.sh /usr/local/bin/start.sh

# EXTERNAL TCP & HTTP
EXPOSE 1113 2113
# INTERNAL TCP & HTTP
EXPOSE 1112 2112

CMD ["/usr/local/bin/start.sh"]
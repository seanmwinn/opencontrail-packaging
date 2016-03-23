FROM stackbrew/ubuntu:trusty
MAINTAINER EMC Cloud Services <autobots@emc.com>

# Setup the workspace for packages to be created
ENV WORKSPACE /var/workspace
ENV USER root

# Setup contrail branch and repo
ENV CONTRAIL_BRANCH R2.20
ENV CONTRAIL_VNC_REPO https://github.com/Juniper/contrail-vnc.git
ENV VERSION 2.20

ENV LIBUV_URL \
    http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.7.5

ENV DATASTAX_URL \
    http://downloads.datastax.com/cpp-driver/ubuntu/14.04/v2.2.0

# Add third party PPA to satisfy contrail dependencies
RUN apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
  software-properties-common wget && \
  add-apt-repository ppa:tcpcloud/extra

RUN wget ${LIBUV_URL}/libuv_1.7.5-1_amd64.deb \
  && dpkg -i libuv_1.7.5-1_amd64.deb

RUN wget ${LIBUV_URL}/libuv-dev_1.7.5-1_amd64.deb \
  && dpkg -i libuv-dev_1.7.5-1_amd64.deb

RUN wget ${DATASTAX_URL}/cassandra-cpp-driver_2.2.0-1_amd64.deb \
  && dpkg -i cassandra-cpp-driver_2.2.0-1_amd64.deb

RUN wget ${DATASTAX_URL}/cassandra-cpp-driver-dev_2.2.0-1_amd64.deb \
  && dpkg -i cassandra-cpp-driver-dev_2.2.0-1_amd64.deb


RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ant \
  autoconf \
  automake \
  bison \
  debhelper \
  default-jdk \
  flex \
  git \
  google-mock \
  javahelper \
  libboost-dev \
  libboost-chrono-dev \
  libboost-date-time-dev \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-python-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libcommons-codec-java \
  libcurl4-openssl-dev \
  libexpat-dev \
  libgettextpo0 \
  libgoogle-perftools-dev \
  libhttp-parser-dev \
  libhttpcore-java \
  libicu-dev \
  libipfix \
  libipfix-dev \
  liblog4cplus-dev \
  liblog4j1.2-java \
  libprotobuf-dev \
  librdkafka1 \
  librdkafka-dev \
  libsnmp-python \
  libtbb-dev \
  libtool \
  libxml2-dev \
  libxml2-utils \
  libzookeeper-mt-dev \
  make \
  module-assistant \
  nodejs \
  protobuf-compiler \
  python-all \
  python-dev \
  python-lxml \
  python-setuptools \
  python-sphinx \
  ruby-ronn \
  scons \
  unzip \
  vim-common \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${WORKSPACE}/pkg

WORKDIR ${WORKSPACE}


RUN wget -O /usr/bin/repo https://storage.googleapis.com/git-repo-downloads/repo\
    && chmod 755 /usr/bin/repo

RUN mkdir -p /root/.ssh
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Initialize the contrail repos using Google's android repo tool
WORKDIR ${WORKSPACE}/pkg

RUN if [[ "${CONTRAIL_BRANCH}" == "default" ]]; \
  then repo init -u ${CONTRAIL_VNC_REPO} -m noauth.xml; \
  else repo init -u ${CONTRAIL_VNC_REPO} -b ${CONTRAIL_BRANCH} -m noauth.xml; \
  fi

RUN repo sync

#Satisfy additional third party dependencies
RUN python third_party/fetch_packages.py

ENTRYPOINT ["make", "-f"]

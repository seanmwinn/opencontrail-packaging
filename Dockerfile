FROM stackbrew/ubuntu:trusty
MAINTAINER EMC Cloud Services <autobots@emc.com>

ENV WORKSPACE=/var/workspace USER=root \
  CONTRAIL_BRANCH=R2.20 CONTRAIL_VNC_REPO=git@github.com:Juniper/contrail-vnc\
  LIBUV_URL="http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.7.5"\
  DATASTAX_URL="http://downloads.datastax.com/cpp-driver/ubuntu/14.04/v2.2.0"

# Setup git user environment
ENV GIT_USER=seanmwinn GIT_EMAIL=sean.pokermaster@gmail.com


# Add third party PPA to satisfy contrail dependencies
RUN apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
  software-properties-common wget && \
  add-apt-repository ppa:tcpcloud/extra

RUN wget ${LIBUV_URL}/libuv_1.7.5-1_amd64.deb \
  && dpkg -i libuv_1.7.5-1_amd64.deb \
  && wget ${LIBUV_URL}/libuv-dev_1.7.5-1_amd64.deb \
  && dpkg -i libuv-dev_1.7.5-1_amd64.deb \
  && wget ${DATASTAX_URL}/cassandra-cpp-driver_2.2.0-1_amd64.deb \
  && dpkg -i cassandra-cpp-driver_2.2.0-1_amd64.deb \
  && wget ${DATASTAX_URL}/cassandra-cpp-driver-dev_2.2.0-1_amd64.deb \
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

# Download google git-repo and mark the binary executable
RUN git clone https://gerrit.googlesource.com/git-repo \
  && chmod +x ${WORKSPACE}/git-repo/repo \
  && mkdir -p /root/.ssh \
  && echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

ADD id_rsa /root/.ssh/id_rsa

ENV REPOBIN ${WORKSPACE}/git-repo
ENV PATH $PATH:$REPOBIN

RUN git config --global user.name ${GIT_USER} \
  && git config --global user.email ${GIT_EMAIL} \
  && git config --global color.ui auto \
  &&chmod 700 /root/.ssh/id_rsa


# Initialize the contrail repos using Google's android repo tool
WORKDIR ${WORKSPACE}/pkg

RUN repo init -u ${CONTRAIL_VNC_REPO} -b ${CONTRAIL_BRANCH} \
  && repo sync \
  && python third_party/fetch_packages.py

ENTRYPOINT ["make", "-f"]


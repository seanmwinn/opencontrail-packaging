FROM stackbrew/ubuntu:trusty
MAINTAINER EMC Cloud Services <autobots@emc.com>

ENV WORKSPACE=/var/workspace USER=nobody \
  CONTRAIL_BRANCH=master CONTRAIL_VNC_REPO=https://github.com/Juniper/contrail-vnc\
  LIBUV_URL="http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.7.5"\
  DATASTAX_URL="http://downloads.datastax.com/cpp-driver/ubuntu/14.04/v2.2.0"

RUN apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
  software-properties-common wget && \
  add-apt-repository 'deb [arch=amd64] http://10.131.236.229/testing contrail-testing-extra main' && \
  wget -O /tmp/rcs-repo-pubkey.asc http://10.131.236.229/key/rcs-repo-pubkey.asc && \
  apt-key add /tmp/rcs-repo-pubkey.asc

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
  && chmod +x ${WORKSPACE}/git-repo/repo

ENV REPOBIN ${WORKSPACE}/git-repo
ENV PATH $PATH:$REPOBIN

# Initialize the contrail repos using Google's android repo tool
WORKDIR ${WORKSPACE}/pkg

RUN repo init -u ${CONTRAIL_VNC_REPO} -b ${CONTRAIL_BRANCH} \
  && sed -i 's#<remote name="github" fetch=".."/>#<remote name="github" \
  fetch="https://github.com/Juniper"/>#g' .repo/manifest.xml

# TODO: Remove when fixed upstream
# Fix ceilometer plugin
RUN mkdir .repo/local_manifests 
ADD ceilometer.xml ${WORKSPACE}/pkg/.repo/local_manifests/ceilometer.xml

RUN repo sync \
  && python third_party/fetch_packages.py

ENTRYPOINT ["make", "-f"]


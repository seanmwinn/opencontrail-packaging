FROM stackbrew/ubuntu:trusty
MAINTAINER EMC Cloud Services <autobots@emc.com>

# Setup the workspace for packages to be created
ENV WORKSPACE /var/workspace

# Add the Google git-repo binaries to the search path
ENV REPOBIN $WORKSPACE/git-repo
ENV PATH $PATH:$REPOBIN

# Setup contrail branch and repo
ENV CONTRAIL_BRANCH R3.0
ENV CONTRAIL_VNC_REPO git@github.com:Juniper/contrail-vnc
ENV VERSION 3.0

# Setup git user environment
ENV GIT_USER <FIXME>
ENV GIT_EMAIL <FIXME>

#Setup environment to build selective packages
ENV TARGETS all
ENV MAKEFILE $WORKSPACE/packages.make

# Add third party PPA to satisfy contrail dependencies
RUN apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install python-software-properties \
  software-properties-common wget && \
  add-apt-repository ppa:tcpcloud/extra

RUN wget \
  http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.7.5/libuv_1.7.5-1_amd64.deb \
  && dpkg -i libuv_1.7.5-1_amd64.deb
  
RUN wget \
  http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.7.5/libuv-dev_1.7.5-1_amd64.deb \
  && dpkg -i libuv-dev_1.7.5-1_amd64.deb

RUN wget \
  http://downloads.datastax.com/cpp-driver/ubuntu/14.04/v2.2.0/cassandra-cpp-driver_2.2.0-1_amd64.deb \
  && dpkg -i cassandra-cpp-driver_2.2.0-1_amd64.deb

RUN wget \
  http://downloads.datastax.com/cpp-driver/ubuntu/14.04/v2.2.0/cassandra-cpp-driver-dev_2.2.0-1_amd64.deb \
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


WORKDIR $WORKSPACE

# Download google git-repo and mark the binary executable
RUN git clone https://gerrit.googlesource.com/git-repo

RUN chmod +x ${WORKSPACE}/git-repo/repo

RUN grep github ~/.ssh/known_hosts || ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN git config --global user.name seanmwinn

RUN git config --global user.email sean.pokermaster@gmail.com

RUN git config --global color.ui auto
# Initialize the contrail repos using Google's android repo tool
RUN if [[ "$CONTRAIL_BRANCH" == "default" ]]; \
  then repo init -u ${CONTRAIL_VNC_REPO}; \
  else repo init -u ${CONTRAIL_VNC_REPO} -b ${CONTRAIL_BRANCH}; \
  fi

RUN repo sync

#Satisfy additional third party dependencies
RUN python ${WORKSPACE}/third_party/fetch_packages.py
  
ENTRYPOINT "${WORKSPACE}/make"

CMD "-f ${MAKEFILE} ${TARGETS}"
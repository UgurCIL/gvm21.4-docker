FROM ubuntu:focal

ARG user_gvm=gvm \
    user_cds=user \
    home_cds=/home/user

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt -o Acquire::http::proxy=false update && \
    apt -o Acquire::http::proxy=false upgrade -yq && \
    apt -o Acquire::http::proxy=false install -yq bison \
        build-essential \
        bzip2 \
        cmake \
        curl \
        doxygen \
        gcc-mingw-w64 \
        gnupg \
        gnutls-bin \
        graphviz \
        heimdal-dev \
        iputils-ping \
        libgcrypt-dev \
        libglib2.0-dev \
        libgnutls28-dev \
        libgpgme-dev \
        libhiredis-dev \
        libical-dev \
        libksba-dev \
        libldap2-dev \
        libmicrohttpd-dev \
        libnet1-dev \
        libopenvas-dev \
        libpcap-dev \
        libpopt-dev \
        libpq-dev \
        libradcli-dev \
        libssh-dev \
        libssl-dev \
        libunistring-dev \
        libxml2-dev \
        net-tools \
        nmap \
        nodejs \
        npm \
        openjdk-8-jre \
        perl-base \
        pkg-config \
        postgresql \
        postgresql-contrib \
        postgresql-server-dev-all \
        python3-cffi \
        python3-defusedxml \
        python3-lxml \
        python3-packaging \
        python3-paramiko \
        python3-pip \
        python3-psutil \
        python3-redis \
        python3-setuptools \
        python3-wrapt \
        redis-server \
        rsync \
        snmp \
        sudo \
        telnet \
        texlive-fonts-recommended \
        texlive-latex-extra \
        traceroute \
        uuid-dev \
        vim \
        virtualenv \
        xml-twig-tools \
        xmlstarlet \
        xmltoman \
        xsltproc \
        yarnpkg

RUN useradd -r -m -U -G sudo -s /bin/bash ${user_cds}

RUN useradd -r -M -U -G sudo -s /usr/sbin/nologin ${user_gvm} && \
    usermod -aG ${user_gvm} ${user_cds}

USER ${user_cds}

ENV INSTALL_PREFIX=/usr/local \
    SOURCE_DIR=${home_cds}/source \
    BUILD_DIR=${home_cds}/build \
    INSTALL_DIR=${home_cds}/install \
    GVM_VERSION=21.4.4 \
    GVM_LIBS_VERSION=21.4.3 \
    GVMD_VERSION=21.4.4 \
    GSA_VERSION=21.4.3 \
    OPENVAS_SMB_VERSION=21.4.0 \
    OPENVAS_SCANNER_VERSION=21.4.3 \
    OSPD_VERSION=21.4.4 \
    OSPD_OPENVAS_VERSION=21.4.3

RUN mkdir -p $SOURCE_DIR && \
    mkdir -p $BUILD_DIR && \
    mkdir -p $INSTALL_DIR

RUN curl -f -L https://github.com/greenbone/gvm-libs/archive/refs/tags/v$GVM_LIBS_VERSION.tar.gz -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/gvm-libs/releases/download/v$GVM_LIBS_VERSION/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc -o $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz.asc && \
    curl -f -L https://github.com/greenbone/gvmd/archive/refs/tags/v$GVMD_VERSION.tar.gz -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/gvmd/releases/download/v$GVMD_VERSION/gvmd-$GVMD_VERSION.tar.gz.asc -o $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz.asc && \
    curl -f -L https://github.com/greenbone/gsa/archive/refs/tags/v$GSA_VERSION.tar.gz -o $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/gsa/releases/download/v$GSA_VERSION/gsa-$GSA_VERSION.tar.gz.asc -o $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz.asc && \
    curl -f -L https://github.com/greenbone/openvas-smb/archive/refs/tags/v$OPENVAS_SMB_VERSION.tar.gz -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/openvas-smb/releases/download/v$OPENVAS_SMB_VERSION/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz.asc && \
    curl -f -L https://github.com/greenbone/openvas-scanner/archive/refs/tags/v$OPENVAS_SCANNER_VERSION.tar.gz -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/openvas-scanner/releases/download/v$OPENVAS_SCANNER_VERSION/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc -o $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz.asc && \
    curl -f -L https://github.com/greenbone/ospd/archive/refs/tags/v$OSPD_VERSION.tar.gz -o $SOURCE_DIR/ospd-$OSPD_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/ospd/releases/download/v$OSPD_VERSION/ospd-$OSPD_VERSION.tar.gz.asc -o $SOURCE_DIR/ospd-$OSPD_VERSION.tar.gz.asc && \
    curl -f -L https://github.com/greenbone/ospd-openvas/archive/refs/tags/v$OSPD_OPENVAS_VERSION.tar.gz -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz && \
    curl -f -L https://github.com/greenbone/ospd-openvas/releases/download/v$OSPD_OPENVAS_VERSION/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc -o $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz.asc

RUN tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION.tar.gz && \
    mkdir -p $BUILD_DIR/gvm-libs && cd $BUILD_DIR/gvm-libs && \
    cmake $SOURCE_DIR/gvm-libs-$GVM_LIBS_VERSION \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DSYSCONFDIR=/etc \
      -DLOCALSTATEDIR=/var \
      -DGVM_PID_DIR=/run/gvm && \
    make DESTDIR=$INSTALL_DIR install

USER root
RUN rsync -avr --ignore-existing $INSTALL_DIR/* /

USER ${user_cds}
RUN rm -rf $INSTALL_DIR/*

RUN tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gvmd-$GVMD_VERSION.tar.gz && \
    mkdir -p $BUILD_DIR/gvmd && cd $BUILD_DIR/gvmd && \
    cmake $SOURCE_DIR/gvmd-$GVMD_VERSION \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DLOCALSTATEDIR=/var \
      -DSYSCONFDIR=/etc \
      -DGVM_DATA_DIR=/var \
      -DGVM_RUN_DIR=/run/gvm \
      -DOPENVAS_DEFAULT_SOCKET=/run/ospd/ospd.sock \
      -DGVM_FEED_LOCK_PATH=/var/lib/gvm/feed-update.lock \
      -DSYSTEMD_SERVICE_DIR=/lib/systemd/system \
      -DDEFAULT_CONFIG_DIR=/etc/default \
      -DLOGROTATE_DIR=/etc/logrotate.d && \
    make DESTDIR=$INSTALL_DIR install

USER root
RUN rsync -avr --ignore-existing $INSTALL_DIR/* /

USER ${user_cds}
RUN rm -rf $INSTALL_DIR/*

RUN tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/gsa-$GSA_VERSION.tar.gz && \
    mkdir -p $BUILD_DIR/gsa && cd $BUILD_DIR/gsa && \
    cmake $SOURCE_DIR/gsa-$GSA_VERSION \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DSYSCONFDIR=/etc \
      -DLOCALSTATEDIR=/var \
      -DGVM_RUN_DIR=/run/gvm \
      -DGSAD_PID_DIR=/run/gvm \
      -DLOGROTATE_DIR=/etc/logrotate.d && \
    make DESTDIR=$INSTALL_DIR install

USER root
RUN rsync -avr --ignore-existing $INSTALL_DIR/* /

USER ${user_cds}
RUN rm -rf $INSTALL_DIR/*

RUN tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION.tar.gz && \
    mkdir -p $BUILD_DIR/openvas-smb && cd $BUILD_DIR/openvas-smb && \
    cmake $SOURCE_DIR/openvas-smb-$OPENVAS_SMB_VERSION \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DCMAKE_BUILD_TYPE=Release && \
    make DESTDIR=$INSTALL_DIR install

USER root
RUN rsync -avr --ignore-existing $INSTALL_DIR/* /

USER ${user_cds}
RUN rm -rf $INSTALL_DIR/*

RUN tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION.tar.gz && \
    mkdir -p $BUILD_DIR/openvas-scanner && cd $BUILD_DIR/openvas-scanner && \
    cmake $SOURCE_DIR/openvas-scanner-$OPENVAS_SCANNER_VERSION \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DSYSCONFDIR=/etc \
      -DLOCALSTATEDIR=/var \
      -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
      -DOPENVAS_RUN_DIR=/run/ospd && \
    make DESTDIR=$INSTALL_DIR install

USER root
RUN rsync -avr --ignore-existing $INSTALL_DIR/* /

USER ${user_cds}
RUN rm -rf $INSTALL_DIR/*

RUN tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/ospd-$OSPD_VERSION.tar.gz && \
    tar -C $SOURCE_DIR -xvzf $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION.tar.gz && \
    cd $SOURCE_DIR/ospd-$OSPD_VERSION && \
    python3 -m pip install . --prefix=$INSTALL_PREFIX --root=$INSTALL_DIR && \
    python3 -m pip install --upgrade psutil==5.5.1 && \
    cd $SOURCE_DIR/ospd-openvas-$OSPD_OPENVAS_VERSION && \
    python3 -m pip install . --prefix=$INSTALL_PREFIX --root=$INSTALL_DIR --no-warn-script-location && \
    python3 -m pip install --user gvm-tools

USER root
RUN rsync -avr --ignore-existing $INSTALL_DIR/* /

USER ${user_cds}
RUN rm -rf $INSTALL_DIR/*

USER root
RUN cp $SOURCE_DIR/openvas-scanner-21.4.3/config/redis-openvas.conf /etc/redis/ && \
    chown redis:redis /etc/redis/redis-openvas.conf && \
    echo "db_address = /run/redis-openvas/redis.sock" | tee -a /etc/openvas/openvas.conf

RUN chown -R gvm:gvm /run/gvm && \
    mkdir /run/redis-openvas && \
    chown -R redis:redis /run/redis-openvas && \
    mkdir /run/ospd && \
    chown -R gvm:gvm /run/ospd && \
    usermod -aG redis gvm && \
    chown -R gvm:gvm /var/lib/gvm && \
    chown -R gvm:gvm /var/lib/openvas && \
    chown -R gvm:gvm /var/log/gvm && \
    chown -R gvm:gvm /run/gvm && \
    chmod -R g+srw /var/lib/gvm && \
    chmod -R g+srw /var/lib/openvas && \
    chmod -R g+srw /var/log/gvm && \
    chown gvm:gvm /usr/local/sbin/gvmd && \
    chmod 6750 /usr/local/sbin/gvmd

RUN echo "%gvm ALL = NOPASSWD: /usr/local/sbin/openvas" | tee -a /etc/sudoers

COPY startup.sh          /home/user/

RUN chmod a+x /home/user/startup.sh

WORKDIR /home/user

ENTRYPOINT ["sh", "/home/user/startup.sh"]
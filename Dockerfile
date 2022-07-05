FROM debian:11

RUN apt-get update && apt-get install -yq gnupg2 wget lsb-release git && \
    wget --http-user=freeswitch --http-password=pat_67bLbQi6g9DVhQowPCXkPy9d -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg  && \
    echo "machine freeswitch.signalwire.com login freeswitch password pat_67bLbQi6g9DVhQowPCXkPy9d" > /etc/apt/auth.conf && \
    echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list && \
    echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list && \
    apt-get update && \
    apt-get -y build-dep freeswitch

# Install spandsp
RUN cd /usr/local/src && \
    git clone https://github.com/freeswitch/spandsp.git && \
    cd spandsp && \
    ./bootstrap.sh -j && \
    ./configure && make && make install

# Install sofia-sip
RUN cd /usr/local/src && \
    git clone https://github.com/freeswitch/sofia-sip.git && \
    cd sofia-sip && \
    ./bootstrap.sh -j && \
    ./configure && make && make install

# 安装Freeswitch
RUN cd /usr/local/src/ && \
    wget https://github.com/signalwire/freeswitch/archive/refs/tags/v1.10.7.tar.gz -O freeswitch-1.10.7.tar.gz && \
    tar -zxf freeswitch-1.10.7.tar.gz && \
    cd /usr/local/src/freeswitch-1.10.7 && \
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH} && \
    ldconfig && \
    ./bootstrap.sh -j && \
    ./configure && \
    make && make install && \
    make cd-sounds-install && \
    make cd-moh-install  && \
    cd libs/unimrcp && \
    autoreconf -fiv && \
    cd -  && \
    cd src/mod/asr_tts/mod_unimrcp && \
    make && make install 

# 软链接
RUN ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/  && \
    ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/

ENTRYPOINT ["freeswitch","-c","-nosql"]
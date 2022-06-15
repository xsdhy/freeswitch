FROM debian:10


RUN apt-get update && \
    apt-get install -y gnupg2 wget lsb-release git

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
    wget https://github.com/signalwire/freeswitch/archive/refs/tags/v1.10.6.tar.gz -O freeswitch-1.10.6.tar.gz && \
    tar -zxf freeswitch-1.10.6.tar.gz && \
    cd /usr/local/src/freeswitch-1.10.6 && \
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH} && \
    ldconfig && \
    ./devel-bootstrap.sh && \
    ./configure  && \
    make && make install

# 软链接
RUN ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/  && \
    ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/



ENTRYPOINT ["freeswitch","-c","-nosql"]
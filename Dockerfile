FROM centos:7


RUN yum update -y && \
    yum install -y git alsa-lib-devel autoconf automake bison broadvoice-devel bzip2 curl-devel libdb4-devel e2fsprogs-devel erlang flite-devel g722_1-devel gcc-c++ gdbm-devel gnutls-devel ilbc2-devel ldns-devel libcodec2-devel libcurl-devel libedit-devel libidn-devel libjpeg-devel libmemcached-devel libogg-devel libsilk-devel libsndfile-devel libtheora-devel libtiff-devel libtool libuuid-devel libvorbis-devel libxml2-devel lua-devel lzo-devel mongo-c-driver-devel ncurses-devel net-snmp-devel openssl-devel opus-devel pcre-devel perl perl-ExtUtils-Embed pkgconfig portaudio-devel postgresql-devel python-devel python-devel soundtouch-devel speex-devel sqlite-devel unbound-devel unixODBC-devel wget which yasm zlib-devel libshout-devel libmpg123-devel lame-devel rpm-build libX11-devel libyuv-devel


# 安装cmake
RUN yum remove cmake -y && \
    yum install libatomic -y && \
    cd /usr/local/src && \
    wget https://cmake.org/files/v3.14/cmake-3.14.7.tar.gz && \
    tar -xzvf cmake-3.14.7.tar.gz && \
    cd cmake-3.14.7 && \
    ./configure && make && make install

# 安装libks
RUN cd /usr/local/src && \
    git clone https://github.com/signalwire/libks.git && \
    cd libks && \
    cmake . && \
    make && make install

# 安装signalwire-c
RUN cd /usr/local/src && \
    git clone https://github.com/signalwire/signalwire-c.git && \
    cd signalwire-c/ && \
    cmake . && \
    make && make install && \
    ln -sf /usr/local/lib64/pkgconfig/signalwire_client.pc /usr/lib64/pkgconfig/signalwire_client.pc

# 安装nasm
RUN cd /usr/local/src && \
    wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.gz && \
    tar -xzvf nasm-2.13.03.tar.gz && \
    cd nasm-2.13.03/ && \
    ./configure && \
    make && make install

# 安装x264
RUN cd /usr/local/src && \
    git clone https://code.videolan.org/videolan/x264.git && \
    cd x264/ && \
    ./configure --disable-asm && \
    make && make install

# 安装libav
RUN cd /usr/local/src && \
    wget http://download1.rpmfusion.org/free/el/updates/7/x86_64/x/x264-libs-0.148-24.20170521gitaaa9aa8.el7.x86_64.rpm && \
    wget http://download1.rpmfusion.org/free/el/updates/7/x86_64/x/x264-devel-0.148-24.20170521gitaaa9aa8.el7.x86_64.rpm && \
    rpm -hiv x264-libs-0.148-24.20170521gitaaa9aa8.el7.x86_64.rpm && \
    rpm -hiv x264-devel-0.148-24.20170521gitaaa9aa8.el7.x86_64.rpm && \
    git clone https://github.com/libav/libav.git && \
    cd libav && \
    ./configure --enable-pic --enable-shared  --enable-libx264 --enable-gpl --extra-libs="-ldl" && \
    make && make install

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
    wget https://files.freeswitch.org/releases/freeswitch/freeswitch-1.10.6.-release.tar.gz && \
    tar -zxf freeswitch-1.10.6.-release.tar.gz && \
    cd /usr/local/src/freeswitch-1.10.6.-release && \
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH} && \
    ldconfig && \
    ./bootstrap.sh && \
    ./configure  && \
    make -j && make install

# 软链接
RUN ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/  && \
    ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/



ENTRYPOINT ["freeswitch","-c","-nosql"]
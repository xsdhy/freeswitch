FROM debian:11

RUN apt-get update && apt-get install -yq gnupg2 wget lsb-release vim tcpdump git cmake && \
    wget --http-user=freeswitch --http-password=pat_V7EZtGcr8oHadnZjgBfbbNcB -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg  && \
    echo "machine freeswitch.signalwire.com login freeswitch password pat_V7EZtGcr8oHadnZjgBfbbNcB" > /etc/apt/auth.conf && \
    echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list && \
    echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list && \
    echo "deb http://packages.irontec.com/debian buster main" >> /etc/apt/sources.list && \
    wget http://packages.irontec.com/public.key -q -O - | apt-key add - && \
    apt-get update && \
    apt-get -y build-dep freeswitch && \
    apt-get -y install sngrep libfftw3-dev libtiff-dev libtiff-tools libpcap-dev libxml2-dev libsndfile-dev libuv1-dev libfltk1.3-dev sox libtool netpbm


RUN cd /usr/local/src && \
    #这个库一直在更新会产生不兼容所以固定分支fs，
    #或者使用固定的 git checkout -b finecode20230705 0d2e6ac65e0e8f53d652665a743015a88bf048d4
    git clone -b fs https://github.com/freeswitch/spandsp.git && \
    cd spandsp && ./bootstrap.sh -j && ./configure && make && make install && \

    cd /usr/local/src && \
    git clone https://github.com/freeswitch/sofia-sip.git && \
    cd sofia-sip && ./bootstrap.sh -j && ./configure && make && make install && \

    cd /usr/local/src && \
    git clone -b v1.8.3 https://github.com/signalwire/libks.git && \
    cd libks && cmake . && make && make install && ldconfig && \

    cd /usr/local/src && \
    git clone -b v1.3.3 https://github.com/signalwire/signalwire-c.git && \
    cd signalwire-c && cmake . && make && make install && ldconfig && \

    cd /usr/local/src/ && \
    git clone -b v1.10.12 https://github.com/signalwire/freeswitch.git freeswitch && \
    cd /usr/local/src/freeswitch && \
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:${PKG_CONFIG_PATH} && \
    ldconfig && \
    ./bootstrap.sh && \
    sed -i 's/endpoints\/mod_skinny/#endpoints\/mod_skinny/' modules.conf  && \
    ./configure  && \
    make && make install && \
    make cd-sounds-install && \
    make cd-moh-install && \
    ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/  && \
    ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/ && \
    # 增加lua支持
    apt-get install -y lua5.2 liblua5.2-dev luarocks && \
    luarocks install luasocket && \
    cd /usr/local/share/lua/5.2 && \
    wget -O xmlsimple.lua https://raw.githubusercontent.com/Cluain/Lua-Simple-XML-Parser/master/xmlSimple.lua && \
    wget -O dkjson.lua https://raw.githubusercontent.com/LuaDist/dkjson/master/dkjson.lua

ENV MY_OPTION=
ENTRYPOINT /usr/local/freeswitch/bin/freeswitch -c $MY_OPTION
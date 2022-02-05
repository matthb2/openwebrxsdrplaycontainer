FROM docker.io/debian:latest

RUN apt-get update && apt-get dist-upgrade -y

RUN apt-get install -y wget vim systemd less git cmake

RUN ln -fs /usr/share/zoneinfo/America/Denver /etc/localtime

RUN cd /root && wget 'https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-3.07.1.run'

#might have to do something with the sample udev rules if running rootless
RUN cd /root && mkdir libsdrplay && bash SDRplay*.run --tar -xf -C libsdrplay/

RUN cp /root/libsdrplay/x86_64/*.so* /usr/lib
RUN cp /root/libsdrplay/scripts/sdrplay.service.usr /etc/systemd/system/sdrplay.service
RUN cp /root/libsdrplay/inc/* /usr/include/
RUN cp /root/libsdrplay/x86_64/sdrplay_apiService /usr/bin/
RUN ln -s /usr/lib/libsdrplay_api.so.3.07 /usr/lib/libsdrplay_api.so

RUN apt-get install soapysdr-tools soapysdr-module-all libsoapysdr-dev python3-soapysdr build-essential pkg-config fftw-dev libfftw3-dev libsamplerate-dev python3-dev python3-setuptools -y

#optional
RUN apt-get install -y librtlsdr-dev 
#RUN apt-get install -y soapyremote-server
#RUN systemctl enable soapyremote-server

RUN cd /root &&\
git clone https://github.com/pothosware/SoapySDRPlay3.git && \
cd SoapySDRPlay3 && \
mkdir build && \
cd build && \
cmake ../ && \
make && make install

RUN systemctl enable sdrplay

RUN cd /root && git clone https://github.com/jketterl/csdr.git && \
cd csdr && mkdir build && cd build && \
cmake ../ && make && make install

RUN cd /root && git clone https://github.com/jketterl/pycsdr.git && \
cd pycsdr && python3 setup.py build && python3 setup.py install

RUN cd /root && git clone https://github.com/jketterl/owrx_connector.git && \
cd owrx_connector && mkdir build && cd build && \
cmake ../ && make && make install

RUN cd /root && git clone https://github.com/jketterl/openwebrx.git

RUN mkdir -p /var/lib/openwebrx
COPY users.json /var/lib/openwebrx/users.json
COPY settings.json /var/lib/openwebrx/settings.json
COPY openwebrx.service /etc/systemd/system/openwebrx.service
RUN systemctl enable openwebrx.service

#optional
RUN apt-get install -y libprotobuf-dev protobuf-compiler libicu-dev libboost-dev libboost-program-options-dev wsjtx 
RUN cd /root && git clone https://github.com/jketterl/codecserver.git && \
cd codecserver && mkdir build && cd build && cmake ../ && make && make install
RUN cd /root && git clone https://github.com/jketterl/digiham.git && \
cd digiham && mkdir build && cd build && cmake ../ && make && make install
#UGLY FIXME needed for pydigiham
RUN mkdir -p /usr/local/include/pycsdr/ && \
cp /root/pycsdr/src/*.hpp /usr/local/include/pycsdr/
RUN cd /root && git clone https://github.com/jketterl/pydigiham.git && cd pydigiham && python3 setup.py install
RUN cd /root && git clone https://github.com/drowe67/codec2.git && cd codec2 &&\
mkdir build && cd build && cmake ../ && make && make install && \
install -m 0755 src/freedv_rx /usr/local/bin
RUN cd /root && git clone https://github.com/mobilinkd/m17-cxx-demod.git && \
cd m17-cxx-demod && mkdir build && cd build && cmake ../ && make && make install
#drm
RUN apt-get install qt5-qmake libpulse0 libfaad2 libopus0 libpulse-dev libfaad-dev libopus-dev libfftw3-dev -y 
RUN cd /root && wget 'https://downloads.sourceforge.net/project/drm/dream/2.1.1/dream-2.1.1-svn808.tar.gz' && \
tar xvzf dream-* && cd dream # && bash -c 'qmake CONFIG+=console' && make && make install


#openwebrx
EXPOSE 8073

#soapyremote
EXPOSE 5513

CMD [ "/sbin/init" ]


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


#openwebrx
EXPOSE 8073

#soapyremote
EXPOSE 5513

CMD [ "/sbin/init" ]


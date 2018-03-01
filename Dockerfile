FROM alpine:latest

ENV OPENZWAVE_VERSION=510a37df958d7b7108781e7a16bfe52e5831514d
ENV OPENZWAVE_CONTROL_PANEL_VERSION=bbbd461c5763faab4949b12da12901f2d6f00f48

RUN apk --no-cache add \
      gnutls \
      gnutls-dev \
      libmicrohttpd \
      libusb \
      eudev \
    && apk --no-cache --virtual .build-dependencies add \
      coreutils \
      eudev-dev \
      g++ \
      gcc \
      git \
      libmicrohttpd-dev \
      libusb-dev \
      linux-headers \
      make \
      openssl \
    && mkdir /zwave \
    && cd /zwave \
    && git clone https://github.com/OpenZWave/open-zwave.git \
    && cd open-zwave \
    && git checkout ${OPENZWAVE_VERSION} \
    && make \
    && cp -r config /zwave/ \
    && cd /zwave \
    && git clone https://github.com/OpenZWave/open-zwave-control-panel.git \
    && cd open-zwave-control-panel \
    && git checkout ${OPENZWAVE_CONTROL_PANEL_VERSION} \
    && sed -i 's/#LIBUSB := -ludev/LIBUSB := -ludev/' Makefile \
    && sed -i 's/#LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) -lresolv/LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) -lresolv/' Makefile \
    && sed -i 's/LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) $(ARCH) -lresolv/#LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB) $(ARCH) -lresolv/' Makefile \
    && make \
    && mv ozwcp cp.js cp.html /zwave \
    && cd /zwave \
    && rm -rf open-zwave open-zwave-control-panel \
    && apk del .build-dependencies

EXPOSE 8090

WORKDIR /zwave

ENTRYPOINT ["/zwave/ozwcp"]

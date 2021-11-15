FROM bitnami/minideb:bullseye AS builder

ENV UTS_SERVER_TAG              0.2.1
ENV UTS_SERVER_DOWNLOAD_URL     https://codeload.github.com/kakwa/uts-server/tar.gz/refs/tags/$UTS_SERVER_TAG

WORKDIR /root/uts-server

RUN install_packages \
    ca-certificates curl libssl-dev cmake libcivetweb-dev gcc g++ make

RUN curl $UTS_SERVER_DOWNLOAD_URL -o uts-server-$UTS_SERVER_TAG.tar.gz \
    && tar --strip-components=1 -zxvf uts-server-$UTS_SERVER_TAG.tar.gz

RUN cmake . \
    && make

FROM bitnami/minideb:bullseye AS runner

WORKDIR /opt/uts-server

RUN install_packages \
    ca-certificates libcivetweb-dev

RUN groupadd -r uts-server \
    && useradd -r -g uts-server uts-server \
    && mkdir /etc/uts-server \
    && chown uts-server:uts-server /etc/uts-server

VOLUME /etc/uts-server

COPY --from=builder /root/uts-server .

EXPOSE 2020

ENTRYPOINT ["./uts-server"]

# -------------------
# The build container
# -------------------
FROM ubuntu:20.10 AS build
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

ENV KAFKA_URL=https://www.nic.funet.fi/pub/mirrors/apache.org/kafka/2.7.0/kafka_2.13-2.7.0.tgz

RUN apt-get -y update && apt-get -y install curl
RUN curl ${KAFKA_URL} -o /opt/kafka.tgz

# -------------------------
# The application container
# -------------------------
#FROM ubuntu:20.10
FROM debian:bullseye-slim
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y upgrade && \
    mkdir -p /usr/share/man/man1/ && \
    apt-get -y install openjdk-17-jre-headless && \
    apt-get clean

COPY --from=build /opt/kafka.tgz /opt/
RUN tar -zxf /opt/kafka.tgz -C /opt/ && rm -f /opt/kafka.tgz && ln -s /opt/kafka_* /opt/kafka 

WORKDIR /opt/kafka

CMD bin/kafka-server-start.sh config/server.properties

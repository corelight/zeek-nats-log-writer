FROM zeek/zeek:6.0

RUN apt-get update && apt-get install --no-install-recommends -y \
	build-essential \
	cmake \
	libpcap-dev \
	libssl-dev \
	libprotobuf-dev \
	protobuf-compiler

RUN git config --global --add safe.directory $(pwd)

WORKDIR /zeek-nats

COPY ./ .

RUN ./configure && make -j8
RUN zeek -N Zeek::NATS

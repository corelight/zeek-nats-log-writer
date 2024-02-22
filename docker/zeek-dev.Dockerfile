FROM zeek/zeek-dev

RUN apt-get update && apt-get install --no-install-recommends -y \
	build-essential \
	cmake \
	libpcap-dev \
	libssl-dev \
	libnats-dev

RUN git config --global --add safe.directory $(pwd)

WORKDIR /zeek-nats

COPY ./ .

RUN ./configure
RUN make install
RUN zeek -N Zeek::NATS

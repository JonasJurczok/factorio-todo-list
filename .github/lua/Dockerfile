FROM ubuntu:latest

LABEL "com.github.actions.name"="package todo list"
LABEL "com.github.actions.description"="run tests/code style and package mod."
LABEL "com.github.actions.icon"="eye"
LABEL "com.github.actions.color"="gray-dark"

LABEL version="1.0.0"

RUN apt-get update -y
RUN apt-get install build-essential curl wget unzip git openssl lua5.2 lua5.2-dev libev-dev libjs-jquery zlib1g-dev jq -y
RUN wget -O /tmp/luarocks.zip https://github.com/keplerproject/luarocks/archive/v3.0.1.zip
RUN unzip /tmp/luarocks.zip -d /tmp
RUN (cd /tmp/luarocks-3.0.1 && ./configure --prefix=/usr --lua-version=5.2)
RUN make -C /tmp/luarocks-3.0.1 build
RUN make -C /tmp/luarocks-3.0.1 install

RUN luarocks install serpent
RUN luarocks install busted
RUN luarocks install luacheck
RUN luarocks install faketorio

COPY "run.sh" "/run.sh"
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
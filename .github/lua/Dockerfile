FROM ubuntu:latest

LABEL "com.github.actions.name"="package todo list"
LABEL "com.github.actions.description"="run tests/code style and package mod."
LABEL "com.github.actions.icon"="eye"
LABEL "com.github.actions.color"="gray-dark"

LABEL version="1.0.0"

RUN apt-get install -y git luajit luarocks

RUN luarocks install serpent
RUN luarocks install busted
RUN luarocks install luacheck
RUN luarocks install faketorio

COPY "build.sh" "/build.sh"
RUN chmod +x /build.sh
ENTRYPOINT ["/build.sh"]
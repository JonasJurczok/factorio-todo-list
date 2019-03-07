FROM jagregory/lua:latest

LABEL "com.github.actions.name"="package todo list"
LABEL "com.github.actions.description"="run tests/code style and package mod."
LABEL "com.github.actions.icon"="eye"
LABEL "com.github.actions.color"="gray-dark"

LABEL version="1.0.0"

COPY "build.sh" "/build.sh"
RUN chmod +x /build.sh
ENTRYPOINT ["/build.sh"]
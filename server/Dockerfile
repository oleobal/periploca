FROM debian:bullseye-slim

RUN \
  apt-get update && \
  apt-get install -y gcc dub zlib1g zlib1g-dev libssl1.1 libssl-dev

# building inside the container, as I am not running Debian and don't want to
# spend ages chasing libs
RUN mkdir -p /source
COPY source /source
COPY dub.json /dub.json
RUN dub build

USER nobody

ENTRYPOINT ["/periploca-server"]
CMD ["--port", "8080"]
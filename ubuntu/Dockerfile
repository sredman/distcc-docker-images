ARG DOCKER_IMAGE=ubuntu:22.04
FROM $DOCKER_IMAGE

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Simon Redman <simon@ergotech.com>"
LABEL author="Konrad Kleine <kkleine@redhat.com>"
LABEL description="A distccd image based on Debian used for distributed"

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="konradkleine/distcc" \
	  org.label-schema.description="distcc" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="konradkleine" \
	  org.label-schema.url="" \
	  org.label-schema.vcs-url="https://github.com/kwk/distcc-docker-images" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t konradkleine/distcc -f Dockerfile ."

ENV LANG=en_US.utf8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install \
	distcc-pump \
  ccache \
	clang \
	build-essential \
#	--no-install-recommends \
  && update-distcc-symlinks \
	&& apt-get -y autoremove --purge \
	&& rm -rf /var/lib/apt/lists/*

ENV HOME=/home/distcc
RUN useradd -s /bin/bash distcc

# Define how to start distccd by default
# (see "man distccd" for more information)
ENTRYPOINT [\
  "distccd", \
  "--daemon", \
  "--no-detach", \
  "--user", "distcc", \
  "--port", "3632", \
  "--stats", \
  "--stats-port", "3633", \
  "--log-stderr", \
  "--listen", "0.0.0.0"\
]

# By default the distcc server will not accept clients from everywhere.
# Feel free to run the docker image with different values for the
# following params.
#CMD [\
#  "--allow", "0.0.0.0/0", \
#  "--nice", "5", \
#]

# 3632 is the default distccd port
# 3633 is the default distccd port for getting statistics over HTTP
EXPOSE \
  3632/tcp \
  3633/tcp

# We check the health of the container by checking if the statistics
# are served. (See
# https://docs.docker.com/engine/reference/builder/#healthcheck)
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1

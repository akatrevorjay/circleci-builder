ARG BUILDER_PARENT_IMAGE="trevorj/boilerplate"
ARG BUILDER_PARENT_TAG="devel"

##
## Python base
##

FROM $BUILDER_PARENT_IMAGE:$BUILDER_PARENT_TAG

RUN lazy-apt \
    build-essential \
    autoconf autoconf-archive pkg-config automake m4 libtool \
    \
    libssl-dev \
    zlib1g-dev \
    \
    patch \
    git \
    \
    bats \
    shunit2 \
    \
    zsh zsh-lovers

COPY build.d build.d
RUN build-parts build.d

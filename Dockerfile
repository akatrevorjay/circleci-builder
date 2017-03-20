FROM trevorj/boilerplate:zesty

# Install base dependencies.
RUN lazy-apt \
    build-essential \
    autoconf autoconf-archive pkg-config automake m4 libtool \
    \
    libssl-dev \
    zlib1g-dev \
    \
    patch \
    git

COPY build.d build.d
RUN build-parts build.d

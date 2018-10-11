ARG BOILERPLATE_PARENT_IMAGE="trevorj/boilerplate"
ARG BOILERPLATE_PARENT_TAG="rolling"

##
## Python base
##

FROM $BOILERPLATE_PARENT_IMAGE:$BOILERPLATE_PARENT_TAG AS python

RUN set -exv \
 && cleanup=no lazy-apt software-properties-common \
 && apt-add-repository -y ppa:deadsnakes/ppa \
 && image-cleanup \
 && :

ARG PYTHON=python3.6

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV="/venv"
ENV PATH="$APP_PATH:$VIRTUAL_ENV/bin:$IMAGE_PATH:$PATH"

RUN set -exv \
 && py="${PYTHON%2}" \
 && py_major="${py%%.*}" \
 \
 && lazy-apt \
        ${py} \
        ${py}-dev \
        \
        ${py_major}-pip \
        ${py_major}-wheel \
        ${py_major}-virtualenv \
        virtualenv \
        \
        python3.7-dev \
 \
 && virtualenv -p "$(which "$PYTHON")" "${VIRTUAL_ENV:?}" \
 && pip install -U pip setuptools wheel \
 \
 && :

##
## builder
##

FROM python AS builder

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
    zsh

COPY build.d build.d
RUN build-parts build.d


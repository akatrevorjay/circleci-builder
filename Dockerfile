ARG CI_BUILDER_PARENT_IMAGE="trevorj/boilerplate"
ARG CI_BUILDER_PARENT_TAG="rolling"
FROM $CI_BUILDER_PARENT_IMAGE:$CI_BUILDER_PARENT_TAG
MAINTAINER Trevor Joynson "<docker@trevor.joynson.io>"

RUN lazy-apt \
    build-essential \
    autoconf autoconf-archive pkg-config automake m4 libtool \
    cmake cmake-extras cmake-fedora extra-cmake-modules \
    \
    libssl-dev \
    zlib1g-dev \
    libffi-dev \
    \
    patch \
    git \
    \
    bats \
    shunit2 \
    shellcheck \
    \
    zsh zsh-lovers \
    \
    vim-nox

COPY build.d build.d
RUN build-parts build.d

##
## Python base
##

RUN set -exv \
 && cleanup=no lazy-apt software-properties-common \
 && apt-add-repository -y ppa:deadsnakes/ppa \
 && image-cleanup \
 && :

# Default python (version or basename)
ARG PYTHON=python3.6
# Pythons you want available
ARG PYTHON_VERSIONS="2.7 3.5 3.6 3.7"

RUN set -exv \
 && lazy-apt \
    \
    $(for ver in $(echo $PYTHON_VERSIONS); do \
        echo "python$ver-dev"; \
        case "$ver" in \
            2*) ;; \
            *)  echo "python$ver-venv" ;; \
        esac; \
    done) \
    \
    python-pip python3-pip python3-setuptools python3-wheel virtualenv \
 && :

RUN set -exv \
 && pip3 install virtualenv-multiver

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV="/venv"
ENV PATH="$APP_PATH:$VIRTUAL_ENV/bin:$IMAGE_PATH:$PATH"

# Setting up a global virtualenv with all pythons avoids any issues after updating pip in a single copy
# (as well as keeps the system nice and clean)
COPY image $IMAGE_ROOT/
RUN set -exv \
 && setup-venv-multiver -p "$PYTHON" "$VIRTUAL_ENV" $PYTHON_VERSIONS

RUN set -exv \
 && for py in $(echo $PYTHON_VERSIONS); do \
        py=python$py \
        &&  $py -m pip install -U \
            setuptools wheel pip \
        &&  $py -m pip install -U \
            coverage \
            coveralls \
            pytest \
            pytest-cov \
            tox \
            ipython \
    ; done


ARG CI_BUILDER_PARENT_IMAGE="trevorj/boilerplate"
ARG CI_BUILDER_PARENT_TAG="bionic"
ARG CI_BUILDER_ABI="unknown"

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
    libpq-dev \
    \
    patch \
    git \
    \
    bats \
    shunit2 \
    shellcheck \
    \
    zsh \
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
ARG PYTHON=python3.8
# Pythons you want available
# note how the default is last
ARG PYTHON_VERSIONS="2.7 3.7 3.9 3.8"

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
    python-pip python3-pip \
 && :

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV="/venv"
ENV PATH="$APP_PATH:$VIRTUAL_ENV/bin:$IMAGE_PATH:$PATH"

RUN set -exv \
 \
 && get_pip_uri="https://bootstrap.pypa.io/get-pip.py" \
 && curl -sSLfo get-pip.py "$get_pip_uri" \
 \
 && for py in $(echo $PYTHON_VERSIONS); do \
        py=python$py \
        \
        &&  ($py -m pip -V || $py get-pip.py) \
        \
        # unfortunately the apt provided copies of these are no bueno
        &&  $py -m pip install -U \
            setuptools wheel pip "virtualenv<20" \
    ; done \
 \
 && rm -vf get-pip.py \
 && :

# Setting up a global virtualenv with all pythons avoids any issues after updating pip in a single copy
# (as well as keeps the system nice and clean)
COPY image $IMAGE_ROOT/
RUN set -exv \
 && setup-venv-multiver -p "$PYTHON" "$VIRTUAL_ENV" $PYTHON_VERSIONS

RUN set -exv \
 && for py in $(echo $PYTHON_VERSIONS); do \
        py=python$py \
        &&  $py -m pip install -U \
            coverage \
            coveralls \
            pytest \
            pytest-cov \
            tox \
            ipython \
    ; done


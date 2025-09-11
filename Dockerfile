FROM ubuntu:24.04

ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=1000
ARG WORKDIR=/work

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    clang \
    flex \
    bison \
    g++ \
    gawk \
    gcc-multilib \
    g++-multilib \
    gettext \
    git \
    libncurses5-dev \
    libssl-dev \
    python3-setuptools \
    rsync \
    swig \
    unzip \
    zlib1g-dev \
    file \
    wget \
    locales \
    quilt \
    ca-certificates \
    curl \
    vim \
    less \
    gpg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

# Configure user and rights
RUN groupmod -g $USER_GID ubuntu && \
    usermod -l $USERNAME -u $USER_UID -g $USER_GID -d /home/$USERNAME -m ubuntu

USER $USERNAME

RUN echo 'QUILT_DIFF_ARGS="--no-timestamps --no-index -p ab --color=auto"' > ~/.quiltrc && \
    echo 'QUILT_REFRESH_ARGS="--no-timestamps --no-index -p ab"' >> ~/.quiltrc && \
    echo 'QUILT_SERIES_ARGS="--color=auto"' >> ~/.quiltrc && \
    echo 'QUILT_PATCH_OPTS="--unified"' >> ~/.quiltrc && \
    echo 'QUILT_DIFF_OPTS="-p"' >> ~/.quiltrc && \
    echo 'EDITOR="vim"' >> ~/.quiltrc

WORKDIR $WORKDIR

CMD ["/bin/bash"]

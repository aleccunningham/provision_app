FROM amazonlinux:2017.03
LABEL Maintainer="Alec Cunningham <aleccunningham96@gmail.com>"

# Use in multi-phase builds, when an init process requests for the container to gracefully exit, so that it may be committed
# Used with alternative CMD (worker.sh), leverages supervisor to maintain long-running processes
ENV SIGNAL_BUILD_STOP=99 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_KILL_FINISH_MAXTIME=5000 \
    S6_KILL_GRACETIME=3000 \
    S6_VERSION=v1.19.1.1

RUN yum update  && \
    yum -y install build-essential python python-dev python-setuptools git libmysqlclient-dev \
    && \
    yum install -yqq \
      curl \
    && \
    # Add S6 for zombie reaping, boot-time coordination, signal transformation/distribution
    curl -L https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz -o /tmp/s6.tar.gz && \
    tar xzf /tmp/s6.tar.gz -C / && \
    rm /tmp/s6.tar.gz && \
    yum remote --purge -yq \
        curl \

# Overlay the root filesystem from this repo
COPY ./docker/root /

RUN mkdir /src

COPY . /src/app

WORKDIR /src/app

ADD requirements.txt /src/app

RUN pip install -r requirements.txt

CMD ["/bin/bash", "/run.sh"]

FROM python:3.8-slim-buster

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y \
        git sysstat vim curl \
        openssh-server \
        apt-transport-https \
        ca-certificates \
        gnupg

RUN curl -fsSL https://get.docker.com | sh
RUN apt-get install -y locales \
    && localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"

ENV TZ Asia/Tokyo
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY requirements.txt /tmp/requirements.txt
RUN pip install -U pip && pip install -r /tmp/requirements.txt

ARG USERNAME=rootless
ARG GROUPNAME=rootless
RUN groupadd -r $USERNAME && useradd -r -g $USERNAME $GROUPNAME
RUN usermod -aG docker,sudo $USERNAME && newgrp docker

RUN apt-get install -y sudo
RUN echo "${USERNAME}:${USERNAME}" |chpasswd
RUN echo "${USERNAME} ALL=(ALL) ALL" >> /etc/sudoers
RUN echo "Defaults visiblepw" >> /etc/sudoers

RUN mkdir /home/$USERNAME && chmod -R +rwx /home/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

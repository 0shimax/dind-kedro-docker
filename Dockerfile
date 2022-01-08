# FROM ubuntu:20.04
FROM python:3.8-slim-buster

ENV DEBIAN_FRONTEND=noninteractive

# for interactive environment
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
# RUN echo $TZ > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

#RUN apt-get install -y --no-install-recommends \
#        python3-dev \
#        python3-pip \
#        python3-setuptools \
#        python3-wheel

#RUN rm -f /usr/bin/python
#RUN rm -f /usr/bin/pip
#RUN rm -f /usr/bin/pdb
#RUN ln -s /usr/bin/python3 /usr/bin/python
#RUN ln -s /usr/bin/pip3 /usr/bin/pip
#RUN ln -s /usr/bin/pdb3 /usr/bin/pdb

#COPY requirements.txt /tmp/requirements.txt
#RUN pip install -U pip && pip install -r /tmp/requirements.txt

# create normal user
#RUN useradd -m user --shell /bin/bash -G docker,sudo
#ARG home_dir=/home/user
#RUN echo 'user:user' |chpasswd
#RUN echo "user ALL=(ALL) ALL" >> /etc/sudoers
#RUN echo "Defaults visiblepw" >> /etc/sudoers

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
#COPY requirements.txt /tmp/requirements.txt
#RUN pip install -U pip --user && pip install -r /tmp/requirements.txt --user
#RUN curl -fsSL https://get.docker.com/rootless | sh

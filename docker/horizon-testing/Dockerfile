############################################################
# Dockerfile to build Horizon Testing container images
# Based on Ubuntu trusty
############################################################
# Set the base image to Ubuntu
FROM ubuntu:trusty
# File Author / Maintainer
MAINTAINER Weezer Su

ARG os_release="master"
RUN apt-get update
RUN apt-get install -y wget git xvfb inetutils-tools inetutils-ping python-setuptools\
 python-dev build-essential python-pip firefox
RUN apt-get remove -y firefox
RUN pip install virtualenv
RUN git clone -b $os_release https://github.com/openstack/horizon.git /opt/horizon
RUN wget https://ftp.mozilla.org/pub/firefox/releases/44.0/linux-x86_64/en-US/firefox-44.0.tar.bz2
RUN tar -xjf firefox-44.0.tar.bz2
RUN mv firefox /opt/firefox44/
RUN ln -s /opt/firefox44/firefox /usr/bin/firefox
ADD horizon.conf /opt/horizon/openstack_dashboard/test/integration_tests/
RUN pip install selenium==2.53.1
RUN pip install -r /opt/horizon/test-requirements.txt
RUN pip install -r /opt/horizon/requirements.txt
ENV NOSE_WITH_XUNIT=1
CMD cd /opt/horizon; ./run_tests.sh -N --selenium-headless --integration

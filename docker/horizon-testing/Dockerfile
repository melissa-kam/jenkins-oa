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
RUN wget -q -O firefox.deb https://sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/firefox-mozilla-build_46.0.1-0ubuntu1_amd64.deb/download
RUN apt-get -y purge firefox
RUN dpkg -i firefox.deb
ADD test-requirements.txt /test-requirements.txt
RUN pip install -r /test-requirements.txt
ADD horizon.conf /opt/horizon/openstack_dashboard/test/integration_tests/
RUN pip install -r /opt/horizon/test-requirements.txt
RUN pip install -r /opt/horizon/requirements.txt
ENV NOSE_WITH_XUNIT=1
CMD cd /opt/horizon; ./run_tests.sh -N --selenium-headless --integration

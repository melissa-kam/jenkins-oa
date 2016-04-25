#!/bin/bash

LINE='----------------------------------------------------------------------'

export DEBIAN_FRONTEND="noninteractive"
export JENKINS_MASTER="jenkins.openstack-ansible.com"
export JENKINS_SLAVE=""
export JENKINS_SECRET=""

function print_info {
  PROC_NAME="- [ $* ] -"
  printf "\n%s%s\n" "$PROC_NAME" "${LINE:${#PROC_NAME}}"
}

function info_block {
  echo "${LINE}"
  print_info "$@"
  echo "${LINE}"
}

# Check that we are in the root path of the cloned repo
if [ ! -d "roles" ] && [ ! -d "scripts" ] && [ ! -d "inventory" ]; then
  info_block "** ERROR **"
  echo "Please execute this script from the root directory of the cloned source code."
  echo -e "Example: /opt/jenkins-oa/\n"
  exit 1
fi

if [ -z "$JENKINS_SLAVE" ]; then
    echo "Enter the Jenkins slave name: "
    read -r JENKINS_SLAVE
fi

if [ -z "$JENKINS_SECRET" ]; then
    echo "Enter the Jenkins slave secret: "
    read -rs JENKINS_SECRET
fi

# Update and grab curl and make sure we can apt over https
apt-get update
apt-get install -y curl apt-transport-https

# Jenkins repo and key -- per jenkins installation page
echo 'deb http://pkg.jenkins-ci.org/debian binary/' > /etc/apt/sources.list.d/jenkins.list
curl -s http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -

# Update again
apt-get update

# Upgrade and install things
apt-get install -y jenkins unzip python-pip python-dev build-essential
pip install --upgrade pip

# shellcheck disable=SC2016
export SHELL_FORMAT='${JENKINS_MASTER}:${JENKINS_SLAVE}:{$JENKINS_SECRET}'
envsubst "$SHELL_FORMAT" < ./scripts/jenkins-slave/jenkins-slave > tmpfile
mv tmpfile /etc/default/jenkins-slave

cp ./scripts/jenkins-slave/jenkins-slave.init /etc/init.d/jenkins-slave
chown root:root /etc/init.d/jenkins-slave
chmod 755 /etc/init.d/jenkins-slave

mkdir -p /opt/jenkins-slave/
chown -R jenkins:jenkins /opt/jenkins-slave/

if [[ ! -e /opt/jenkins-slave/slave.jar ]]; then
  unzip -j /usr/share/jenkins/jenkins.war WEB-INF/slave.jar -d /opt/jenkins-slave/
fi

# Restart daemon under jenkins-slave alias
service jenkins-slave restart

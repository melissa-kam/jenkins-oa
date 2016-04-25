#!/usr/bin/env bash

# This script prepares, deploys, and tests the `rpc-openstack` and
# `openstack-ansible` projects within a variety of environments. Each func-
# tion corresponds to a Ansible role within the `multinode.yml` playbook.

# They're run in a set order and perform documented installation steps until
# they either complete or fail. The idea of the tag system is to be able to
# have flexible jenkins jobs, without complex job relationships in jenkins.


## Job variables
LAB=${LAB:-master}
TAGS=${TAGS:-prepare}

## Jenkins variables
JENKINS_RPC_URL=${JENKINS_RPC_URL:-https://github.com/rcbops/jenkins-rpc}
JENKINS_RPC_BRANCH=${JENKINS_RPC_BRANCH:-master}

## Product Variables
PRODUCT=${PRODUCT:-rpc-openstack}
PRODUCT_REPO_DIR=${PRODUCT_REPO_DIR:-"/opt/${PRODUCT}"}
PRODUCT_URL=${PRODUCT_URL:-https://github.com/rcbops/rpc-openstack}
PRODUCT_BRANCH=${PRODUCT_BRANCH:-master}

# RPC Variables
RPC_FEATURES=${RPC_FEATURES:-()} # comma seperated list
ANSIBLE_RPC_FEATURES=${ANSIBLE_RPC_FEATURES:-""}

# Product Config Variables
CONFIG_PREFIX=${CONFIG_PREFIX:-openstack}
TEMPEST_SCRIPT_PARAMETERS=${TEMPEST_SCRIPT_PARAMETERS:-api}

# Shell Variables
ANSIBLE_FORCE_COLOR=${ANSIBLE_FORCE_COLOR:-1}
ANSIBLE_OPTIONS=${ANSIBLE_OPTIONS:-"-v"}
FORKS=${FORKS:-250}
SLEEP_TIME=${SLEEP_TIME:-0}

function join {
  local IFS="$1"; shift; echo "$*";
}

function main {
  # Variables based on products' respective documentation
  case "$PRODUCT" in
    "rpc-openstack" )
      PRODUCT_URL="https://github.com/rcbops/rpc-openstack"
      OA_REPO_DIR="${PRODUCT_REPO_DIR}/openstack-ansible"
      ;;
    "openstack-ansible" )
      PRODUCT_URL="https://github.com/openstack/openstack-ansible"
      OA_REPO_DIR=$PRODUCT_REPO_DIR
      ;;
    * )
      echo "Invalid product name. Choices: 'rpc-openstack' or 'openstack-ansible'"
      ;;
  esac

  export ANSIBLE_FORCE_COLOR

  # Join feature tags in comma-deliminated format; remove trailing comma
  if [[ $PRODUCT == "rpc-openstack" ]]; then
    TAGS=$(join , "${PRODUCT}" "${RPC_FEATURES[@]}" "$ANSIBLE_RPC_FEATURES" | sed 's/,*$//g')
  fi

  ansible-playbook \
    --extra-vars="product_repo_dir=${PRODUCT_REPO_DIR}" \
    --extra-vars="oa_repo_dir=${OA_REPO_DIR}" \
    --extra-vars="product_url=${PRODUCT_URL}" \
    --extra-vars="product_branch=${PRODUCT_BRANCH}" \
    --tags="$TAGS" \
    "$ANSIBLE_OPTIONS" \
    multinode.yml
}

main "$@"

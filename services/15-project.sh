#!/bin/sh

set -e

if [ "${DEBUG}" = true ]; then
  set -x
fi

INSTALL_PROJECT=${INSTALL_PROJECT:-0}
PROJECT_GIT_REPO=${PROJECT_GIT_REPO}
PROJECT_GIT_TAG=${PROJECT_GIT_TAG:-HEAD}

if [ ! "${INSTALL_PROJECT}" -eq 0 ]; then

  if [ -n "$PROJECT_GIT_REPO" ]; then

    cd /var/www/html
    set +e
    git rev-parse --git-dir > /dev/null 2>&1; IS_GIT=$?
    set -e

    if [ ! "$IS_GIT" -eq 0 ]; then
      cd /var/www/
      rm -rf /var/www/html/*
      find /var/www/html/ -maxdepth 1 -type f -name ".*" -delete
      git clone --no-checkout ${PROJECT_GIT_REPO} html
    fi

    cd /var/www/html
    git checkout ${PROJECT_GIT_TAG}
    git submodule update --init --recursive

  fi

fi

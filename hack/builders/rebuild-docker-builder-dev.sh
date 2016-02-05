#!/bin/bash

# See README.md for more info.

source "$(dirname ${BASH_SOURCE})/rebuild-builder-image-dev.sh"

image="openshift/origin-docker-builder"

rebuild-builder-image "${image}"

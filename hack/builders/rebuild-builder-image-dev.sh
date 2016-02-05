#!/bin/bash

# This script can rebuild OpenShift builder images quickly, by copying a new
# version of the openshift binary into an existing builder image (probably
# obtained from Docker Hub or via `make release`). This is suitable for
# developing and experimenting with code in pkg/build/builder.

set -o errexit
set -o nounset
set -o pipefail                ## FIXME

function info() {
  echo -e "\e[00;34m$@\e[00m"
}

# rebuild-builder-image takes a single argument, the name of an OpenShift
# builder image, e.g., "openshift/origin-docker-builder". It will overwrite the
# openshift binary in the the latest tag, so that the next builds started in a
# server running with the '--latest-images' flag will pick up the code in the
# new binary.
function rebuild-builder-image() {
  image="$1"
  base_image="${image}-base-$(tr -dc '[:lower:][:digit:]' </dev/urandom | dd bs=4 count=3 2>/dev/null)"                        ## FIXME

  tmpdir="$(mktemp -d)"
  openshiftbin="$(which openshift)"

  info "Copying openshift binary to temporary work directory ..."
  cp -av "${openshiftbin}" "${tmpdir}"

  # Find base image id to avoid stacking multiple COPY layers
  base_id=$(docker history --no-trunc ${image} | \
            grep -v 'COPY file.*in /usr/bin/openshift' | \
            awk 'NR==2 {print $1}')

  info "Tagging the base Docker image ${base_image} ..."
  docker tag "${base_id}" "${base_image}"

  # Write Dockerfile
  set +e
  read -d '' Dockerfile <<EOF
  FROM ${base_image}

  COPY openshift /usr/bin/openshift
EOF
  set -e
  echo "${Dockerfile}" > ${tmpdir}/Dockerfile

  info "Building Docker image ${image} ..."
  docker build -t "${image}" "${tmpdir}"

  # Cleanup
  rm -vrf "${tmpdir}"
  docker rmi "${base_image}"

  info "Done."
}

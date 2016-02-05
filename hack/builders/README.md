# OpenShift Builder Images

OpenShift builds use Docker images that know how to generate (build) other
Docker images.

Each build strategy is supported by a builder image:

* Source-to-Image: `openshift/origin-sti-builder`
* Docker: `openshift/origin-docker-builder`
* Custom: any user provided image


## Making Changes To Builder Images

The code in `pkg/build/builders` is what gets executed during a build of a
certain strategy. During development, in order to see the effects of your
changes in code, you have to not only recompile OpenShift (`make build`), but
also rebuild the builder images you're interested in.

The images are normally built by `make release`, but that also does several
other things and takes way too much time to complete, being unsuitable for
interactive coding.

The scripts in this directory are shortcuts to update the `openshift` binary in
existing images, so that it makes the feedback loop much faster.

To use this effectively, you should start your development server with the
'--latest-images' option.

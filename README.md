[![Build Status](https://ci.centos.org/buildStatus/icon?job=devtools-eclipse-che-build-dockerfiles)](https://ci.centos.org/job/devtools-eclipse-che-build-dockerfiles)

# che-dockerfiles
Che dockerfiles extended with security in mind.

## Repo Structure
This repo is divided into two directories:
- `./recipes/context` contains a shared build context for all docker images (e.g. the `entrypoint.sh` script, and helpful scripts that are used in building dependencies within images)
- `./recipes/dockerfiles` contains subdirectories for each docker image.

As a result, to build an image locally, it is necessary to set the build context to `./recipes` and explicitly specify the dockerfile being built. E.g. from the root of the repo
```
docker build \
  -t spring-boot:local \
  -f ./recipes/dockerfiles/spring-boot/Dockerfile \
  ./recipes/
```

The scripts in `./recipes/context` are, in short:
- `download-maven-deps.sh <mission> <runtime> ...` parses the latest booster version number from the osio rest endpoint, clones git repositories, and executes a maven build to cache the dependencies required in the local maven repository. See [1] for details of what is required for `mission` and `runtime`
- `maven-deps.install <mission> <runtime> ...` wraps `download_maven_deps.sh`, to install required dependencies for parsing version numbers (`jq`) and clean up afterwards.
- `entrypoint.sh` is a shared entrypoint for most of the dockerfiles
- `general-deps.install <OPENSHIFT_VERSION> [<JAVA_VERSION>]` is a script that stores dependencies for running on osio and is generally run in every (applicable) docker image. All non-temporary dependencies should be included here.
- `grant-access-arbitirary-UID.sh` allows arbitrary users to access the `/home/user`, `/etc/passwd`, `/etc/group`, and `/projects` directories
- `nodejs.install` is responsible for installing nodejs.
- `nss_wrapper.install` is responsible for installing nss_wrapper.

[1] https://forge.api.openshift.io/api/booster-catalog

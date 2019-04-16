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
- `entrypoint.sh` is a shared entrypoint for most of the dockerfiles
- `general-deps.install <OPENSHIFT_VERSION> [<JAVA_VERSION>]` is a script that stores dependencies for running on osio and is generally run in every (applicable) docker image. All non-temporary dependencies should be included here.
- `grant-access-arbitirary-UID.sh` allows arbitrary users to access the `/home/user`, `/etc/passwd`, `/etc/group`, and `/projects` directories
- `nodejs.install` is responsible for installing nodejs.
- `nss_wrapper.install` is responsible for installing nss_wrapper.

## Quay.io repositories
The CI build pushes artifacts to dockerhub and [quay.io](https://quay.io/organization/openshiftio). For automatic builds to succeed, repositories should be created on quay.io beforehand, one for each dockerfile.

Repository names come directly from folder names in `./recipes/dockerfiles`, with `che-` prepended (e.g. `che-centos_jdk8`). The process for creating new repos on quay.io is documented [here](https://gitlab.cee.redhat.com/service/app-interface/tree/master#create-a-quay-repository-for-an-onboarded-app-app-sreapp-1yml) and must be done for any new dockerimages added to this repo.

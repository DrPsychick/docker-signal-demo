#!/bin/bash

# required Travis-ci secret variables (all other variables to be set in .travis.yml)
# DOCKER_PASS, DOCKER_USER

# login to docker
echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin &> /dev/null || exit 1

# push dev image (only latest)
if [ "$TRAVIS_BRANCH" = "dev" -a "$UBUNTU_VERSION" = "latest" ]; then
  echo "build and push docker image for version $IMAGE:dev"
  docker build --progress plain --build-arg UBUNTU_VERSION=$UBUNTU_VERSION \
    -t $IMAGE:dev --push .
fi

# push master images (not when it's a pull request)
if [ "$TRAVIS_BRANCH" = "master" -a "$TRAVIS_PULL_REQUEST" = "false" ]; then
  # tag including UBUNTU version
  echo "build and push docker image for version $IMAGE:$UBUNTU_VERSION"
  docker build --progress plain --build-arg UBUNTU_VERSION=$UBUNTU_VERSION \
    -t $IMAGE:$UBUNTU_VERSION --push .
fi

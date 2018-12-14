#!/usr/bin/env bash
set -e

PROJECT=librenms
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_TAG=docker_build
BUILD_WORKINGDIR=${BUILD_WORKINGDIR:-.}
DOCKERFILE=${DOCKERFILE:-Dockerfile}
VCS_REF=${TRAVIS_COMMIT::8}
RUNNING_TIMEOUT=120
RUNNING_LOG_CHECK="snmpd entered RUNNING state"

DOCKER_USERNAME=${DOCKER_USERNAME:-librenms}
DOCKER_REPONAME=${DOCKER_REPONAME:-librenms}
DOCKER_LOGIN=${DOCKER_LOGIN:-librenmsbot}
QUAY_USERNAME=${QUAY_USERNAME:-librenms}
QUAY_REPONAME=${QUAY_REPONAME:-librenms}
QUAY_LOGIN=${QUAY_LOGIN:-librenms+travis}

# Check local or travis
BRANCH=${TRAVIS_BRANCH:-local}
if [[ ${TRAVIS_PULL_REQUEST} == "true" ]]; then
  BRANCH=${TRAVIS_PULL_REQUEST_BRANCH}
fi
DOCKER_TAG=${BRANCH:-local}
if [[ "$BRANCH" == "master" ]]; then
  DOCKER_TAG=latest
elif [[ "$BRANCH" == "local" ]]; then
  BUILD_DATE=
  VERSION=local
fi

echo "PROJECT=${PROJECT}"
echo "BUILD_DATE=${BUILD_DATE}"
echo "BUILD_TAG=${BUILD_TAG}"
echo "BUILD_WORKINGDIR=${BUILD_WORKINGDIR}"
echo "DOCKERFILE=${DOCKERFILE}"
echo "VCS_REF=${VCS_REF}"
echo "DOCKER_USERNAME=${DOCKER_USERNAME}"
echo "DOCKER_REPONAME=${DOCKER_REPONAME}"
echo "QUAY_USERNAME=${QUAY_USERNAME}"
echo "QUAY_REPONAME=${QUAY_REPONAME}"
echo "TRAVIS_BRANCH=${TRAVIS_BRANCH}"
echo "TRAVIS_PULL_REQUEST=${TRAVIS_PULL_REQUEST}"
echo "BRANCH=${BRANCH}"
echo "DOCKER_TAG=${DOCKER_TAG}"
echo

# Build
echo "### Build"
docker build \
  --build-arg BUILD_DATE=${BUILD_DATE} \
  --build-arg VCS_REF=${VCS_REF} \
  --build-arg VERSION=${VERSION} \
  -t ${BUILD_TAG} -f ${DOCKERFILE} ${BUILD_WORKINGDIR}
echo

echo "### Test"
docker rm -f ${PROJECT} ${PROJECT}-db > /dev/null 2>&1 || true
docker network rm ${PROJECT} > /dev/null 2>&1 || true
docker network create -d bridge ${PROJECT}
docker run -d --network=${PROJECT} --name ${PROJECT}-db --hostname ${PROJECT}-db \
  -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" \
  -e "MYSQL_DATABASE=librenms" \
  -e "MYSQL_USER=librenms" \
  -e "MYSQL_PASSWORD=asupersecretpassword" \
  mariadb:10.2 \
  mysqld --sql-mode= --innodb-file-per-table=1 --lower-case-table-names=0
docker run -d --network=${PROJECT} --link ${PROJECT}-db -p 8000:80 \
  -e "DB_HOST=${PROJECT}-db" \
  -e "DB_NAME=librenms" \
  -e "DB_USER=librenms" \
  -e "DB_PASSWORD=asupersecretpassword" \
  --name ${PROJECT} ${BUILD_TAG}
echo

echo "### Waiting for ${PROJECT} to be up..."
TIMEOUT=$((SECONDS + RUNNING_TIMEOUT))
while read LOGLINE; do
  echo ${LOGLINE}
  if [[ ${LOGLINE} == *"${RUNNING_LOG_CHECK}"* ]]; then
    echo "Container up!"
    break
  fi
  if [[ $SECONDS -gt ${TIMEOUT} ]]; then
    >&2 echo "ERROR: Failed to run ${PROJECT} container"
    docker rm -f ${PROJECT} > /dev/null 2>&1 || true
    exit 1
  fi
done < <(docker logs -f ${PROJECT} 2>&1)
echo

CONTAINER_STATUS=$(docker container inspect --format "{{.State.Status}}" ${PROJECT})
if [[ ${CONTAINER_STATUS} != "running" ]]; then
  >&2 echo "ERROR: Container ${PROJECT} returned status '$CONTAINER_STATUS'"
  docker rm -f ${PROJECT} > /dev/null 2>&1 || true
  exit 1
fi
docker rm -f ${PROJECT} > /dev/null 2>&1 || true
echo

if [ "${VERSION}" == "local" -o "${TRAVIS_PULL_REQUEST}" == "true" ]; then
  echo "INFO: This is a PR or a local build, skipping push..."
  exit 0
fi
if [[ ! -z ${DOCKER_PASSWORD} ]]; then
  echo "### Push to Docker Hub..."
  echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_LOGIN" --password-stdin > /dev/null 2>&1
  docker tag ${BUILD_TAG} ${DOCKER_USERNAME}/${DOCKER_REPONAME}:${DOCKER_TAG}
  docker tag ${BUILD_TAG} ${DOCKER_USERNAME}/${DOCKER_REPONAME}:${VERSION}
  docker push ${DOCKER_USERNAME}/${DOCKER_REPONAME}
  if [[ ! -z ${DOCKER_PASSWORD} ]]; then
    echo "Call MicroBadger hook"
    curl -X POST ${MICROBADGER_HOOK}
  fi
  echo
fi
if [[ ! -z ${QUAY_PASSWORD} ]]; then
  echo "### Push to Quay..."
  echo "$QUAY_PASSWORD" | docker login quay.io --username "$QUAY_LOGIN" --password-stdin > /dev/null 2>&1
  docker tag ${BUILD_TAG} quay.io/${QUAY_USERNAME}/${QUAY_REPONAME}:${DOCKER_TAG}
  docker tag ${BUILD_TAG} quay.io/${QUAY_USERNAME}/${QUAY_REPONAME}:${VERSION}
  docker push quay.io/${QUAY_USERNAME}/${QUAY_REPONAME}
fi

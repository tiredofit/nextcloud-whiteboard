ARG DISTRO="alpine"
ARG DISTRO_VARIANT="3.20"

FROM docker.io/tiredofit/${DISTRO}:${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG NEXTCLOUD_WHITEBOARD_VERSION
ARG NEXTCLOUD_WHITEBOARD_REPO_URL

ENV NEXTCLOUD_WHITEBOARD_VERSION=${NEXTCLOUD_WHITEBOARD_VERSION:-"v1.1.0"} \
    NEXTCLOUD_WHITEBOARD_REPO_URL=${NEXTCLOUD_WHITEBOARD_REPO_URL:-"https://github.com/nextcloud/whiteboard"} \
    CONTAINER_NAME=nextcloud-app \
    IMAGE_NAME="tiredofit/nextcloud-whiteboard" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-nextcloud-whiteboard/"

RUN source /assets/functions/00-container && \
    set -x && \
    addgroup -S -g 1000 ncwhiteboard && \
    adduser -D -S -s /sbin/nologin \
            -h /dev/null \
            -G ncwhiteboard \
            -g "ncwhiteboard" \
            -u 1000 ncwhiteboard \
            && \
    package update && \
    package upgrade && \
    package install .ncwhiteboard-build-deps \
                        git \
                    && \
    package install .ncwhiteboard-run-deps \
                        nodejs \
                        npm \
                    && \
    \
    clone_git_repo "${NEXTCLOUD_WHITEBOARD_REPO_URL}" "${NEXTCLOUD_WHITEBOARD_VERSION}" /app && \
    npm install --global clean-modules && \
    npm install && \
    npm run build && \
    rm -rf .git && \
    \
    package remove .ncwhiteboard-build-deps \
                   && \
    package cleanup

COPY install /

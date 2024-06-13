#!/bin/bash
# Podman login script for user sessions

# USER_CONTAINER_IMAGE="user-session-image:latest"
USER_CONTAINER_IMAGE="amazonlinux:latest"

# Generate a unique container name
CONTAINER_NAME="user_session_${USER}_$(date +%s)"

# Run the Podman container
exec podman run --rm -it \
    --name ${CONTAINER_NAME} \
    --userns=keep-id \
    --hostname ${HOSTNAME} \
    --network host \
    --memory 512m --cpus 1 \
    --volume /home/${USER}:/home/${USER} \
    ${USER_CONTAINER_IMAGE} /bin/bash

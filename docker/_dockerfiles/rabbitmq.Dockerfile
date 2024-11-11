# https://github.com/docker-library/rabbitmq/blob/36e4d246e934a96b1c3a920e398f96434f3fc34c/4.0/alpine/management/Dockerfile
# https://github.com/docker-library/rabbitmq/blob/4d384714be0c4e4c528745136c38b7f89620410f/4.0/alpine/Dockerfile

ARG IMAGE_NAME=rabbitmq
ARG IMAGE_TAG=4.0.2-management-alpine

FROM ${IMAGE_NAME}:${IMAGE_TAG} AS rabbitmq

ENV RABBITMQ_PID_FILE=/var/lib/rabbitmq/mnesia/rabbitmq

ARG CONFIG_DIR=./docker/_configs/rabbitmq

ARG IMAGE_USER_NAME=rabbitmq
ARG IMAGE_USER_ID=100
ARG IMAGE_GROUP_NAME=rabbitmq
ARG IMAGE_GROUP_ID=101

# copy initialization script
COPY --chown=${IMAGE_USER_NAME}:${IMAGE_GROUP_NAME} ${CONFIG_DIR}/set-creds.sh /usr/local/bin/set-creds.sh
RUN chmod +x /usr/local/bin/set-creds.sh

USER ${IMAGE_USER_NAME}

ENTRYPOINT ["set-creds.sh"]
CMD ["rabbitmq-server"]

ARG IMAGE_NAME=mongodb/mongodb-community-server
ARG IMAGE_TAG=7.0.3-ubi9

FROM ${IMAGE_NAME}:${IMAGE_TAG} AS python

ARG CONFIG_DIR=./docker/_configs/mongo
ARG INSTALL_SYS_PACKAGES=""

ARG IMAGE_USER_NAME=mongod
ARG IMAGE_USER_ID=1000
ARG IMAGE_GROUP_NAME=mongod
ARG IMAGE_GROUP_ID=1000

USER root

# copy healthcheck script
COPY --chown=${IMAGE_USER_NAME}:${IMAGE_GROUP_NAME} ${CONFIG_DIR}/check-mongo /
RUN chmod +x /check-mongo

# copy initialization script
COPY --chown=${IMAGE_USER_NAME}:${IMAGE_GROUP_NAME} ${CONFIG_DIR}/init-mongo /docker-entrypoint-initdb.d/init-mongo.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-mongo.sh

USER ${IMAGE_USER_NAME}

ENTRYPOINT ["python3", "/usr/local/bin/docker-entrypoint.py"]
CMD ["mongod"]

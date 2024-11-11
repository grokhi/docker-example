# https://github.com/mongo-express/mongo-express-docker/blob/403467f350d819b404f3d5150be7776217e810b7/1.0/20-alpine3.19/Dockerfile

ARG IMAGE_NAME=mongo-express
ARG IMAGE_TAG=1.0.2-20-alpine3.19

FROM ${IMAGE_NAME}:${IMAGE_TAG} AS mongoexpress

ARG IMAGE_USER_NAME=node
ARG IMAGE_USER_ID=1000
ARG IMAGE_GROUP_NAME=node
ARG IMAGE_GROUP_ID=1000

# for healthcheck triggering
RUN apk update && apk add --no-cache curl

# create user and group
#  && echo ${USER_NAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER_NAME} \
#  && chmod 0440 /etc/sudoers.d/${USER_NAME}

USER ${IMAGE_USER_NAME}

EXPOSE 8081
ENTRYPOINT [ "/sbin/tini", "--", "/docker-entrypoint.sh"]
CMD ["mongo-express"]

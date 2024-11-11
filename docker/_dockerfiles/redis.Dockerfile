# https://github.com/redis/docker-library-redis/blob/e5650da99bb377b2ed4f9f1ef993ff24729b1c16/7.4/alpine/Dockerfile

ARG IMAGE_NAME=redis
ARG IMAGE_TAG=7.4.1-alpine

FROM ${IMAGE_NAME}:${IMAGE_TAG} AS redis

ARG IMAGE_USER_NAME=redis
ARG IMAGE_USER_ID=999
ARG IMAGE_GROUP_NAME=redis
ARG IMAGE_GROUP_ID=1000

USER ${IMAGE_USER_NAME}

EXPOSE 6379
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["redis-server"]

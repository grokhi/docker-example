# https://github.com/pgadmin-org/pgadmin4/blob/master/Dockerfile

ARG IMAGE_NAME=dpage/pgadmin4
ARG IMAGE_TAG=2024-10-19-2

FROM ${IMAGE_NAME}:${IMAGE_TAG} AS pgadmin

USER root

ARG IMAGE_USER_NAME=pgadmin
ARG IMAGE_USER_ID=5050
ARG IMAGE_GROUP_NAME=root
ARG IMAGE_GROUP_ID=0

# for healthcheck triggering
RUN apk update && apk add --no-cache curl

USER ${IMAGE_USER_NAME}

EXPOSE 80 443
ENTRYPOINT ["/entrypoint.sh"]

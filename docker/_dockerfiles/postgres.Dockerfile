# https://github.com/docker-library/postgres/blob/172544062d1031004b241e917f5f3f9dfebc0df5/17/alpine3.20/Dockerfile

ARG IMAGE_NAME=postgres
ARG IMAGE_TAG=17.0-alpine3.20

FROM ${IMAGE_NAME}:${IMAGE_TAG} AS postgres

ARG CONFIG_DIR=./docker/_configs/postgres

# copy initialization script
COPY ${CONFIG_DIR}/initdb/ /docker-entrypoint-initdb.d
RUN chmod +x /docker-entrypoint-initdb.d/*

# copy maintanance scripts
COPY ${CONFIG_DIR}/maintenance /usr/local/bin/maintenance
RUN chmod +x /usr/local/bin/maintenance/*
RUN mv /usr/local/bin/maintenance/* /usr/local/bin \
    && rmdir /usr/local/bin/maintenance

#ARG IMAGE_USER_NAME=postgres
#ARG IMAGE_USER_ID=70
#ARG IMAGE_GROUP_NAME=postgres
#ARG IMAGE_GROUP_ID=70
#
#USER ${IMAGE_USER_NAME}

EXPOSE 5432
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]

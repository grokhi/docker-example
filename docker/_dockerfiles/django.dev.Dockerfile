ARG IMAGE_NAME=python
ARG IMAGE_TAG=3.12.2-slim-bookworm

FROM ${IMAGE_NAME}:${IMAGE_TAG} AS python


# Python 'build' stage
FROM python AS python-build-stage

ENV PATH="/usr/bin:${PATH}"
ARG BUILD_ENVIRONMENT=default

# install build dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  # dependencies for building Python packages
  build-essential \
  # psycopg dependencies
  libpq-dev \
  # dependencies for django-migration-vis
  python3-pydot \
  graphviz

# requirements are installed here to ensure they will be cached
COPY ./requirements .

# create python dependency and subdependency wheels
RUN pip wheel --wheel-dir /usr/src/app/wheels -r ${BUILD_ENVIRONMENT}.txt


# Python 'run' stage
FROM python AS python-run-stage

ARG BUILD_ENVIRONMENT=default
ARG APP_HOME=/app
ARG SCRIPTS_DIR=/scripts

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV BUILD_ENV=${BUILD_ENVIRONMENT}

ARG IMAGE_USER_NAME=user
ARG IMAGE_USER_ID=1000
ARG IMAGE_GROUP_NAME=user
ARG IMAGE_GROUP_ID=1000

ARG CONFIG_DIR=./docker/_configs/django
ARG INSTALL_SYS_PACKAGES="bash-completion"

WORKDIR ${APP_HOME}

# create devcontainer user and add it to sudoers
RUN groupadd --gid ${IMAGE_GROUP_ID} ${IMAGE_GROUP_NAME} \
  && useradd --uid ${IMAGE_USER_ID} --gid ${IMAGE_GROUP_NAME} --shell /bin/bash --create-home ${IMAGE_USER_NAME}

# install required system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  # psycopg dependencies
  libpq-dev \
  # for healthchecks endpoints triggering
  curl \
  # translations dependencies
  gettext \
  # other dependencies
  ${INSTALL_SYS_PACKAGES} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

# copy python dependency wheels from python-build-stage
COPY --from=python-build-stage /usr/src/app/wheels  /wheels/

# use wheels to install python dependencies
RUN pip install --no-cache-dir --no-index --find-links=/wheels/ /wheels/* \
  && rm -rf /wheels/

# copy entrypoint and start scripts
COPY --chown=${IMAGE_USER_NAME}:${IMAGE_GROUP_NAME} ${CONFIG_DIR}/ /
RUN sed -i 's/\r$//g' /entrypoint /start \
    /start-celeryworker /start-celerybeat /start-celeryflower \
    /check-celeryworker /check-celerybeat /check-celeryflower
RUN chmod +x /entrypoint /start \
    /start-celeryworker /start-celerybeat /start-celeryflower \
    /check-celeryworker /check-celerybeat /check-celeryflower

# copy application code to WORKDIR
COPY . ${APP_HOME}
COPY ../scripts ${SCRIPTS_DIR}

# switch to non-root user
USER ${IMAGE_USER_NAME}

# set availability scripts to be executed on the start
ENTRYPOINT ["/entrypoint"]

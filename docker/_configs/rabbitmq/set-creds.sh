#!/bin/sh

set -o nounset

# -----------------------------------------------------------------------------

mask_secret() {
    local secret="$1"
    local length=${#secret}
    local masked=$(printf '%*s' "$length" '' | tr ' ' '*')
    echo "$masked"
}

create_user() {
  local username="$1"
  local password="$2"

  rabbitmqctl add_user "$username" "$password" 2>/dev/null
  rabbitmqctl set_user_tags "$username" administrator
  rabbitmqctl set_permissions -p / "$username" ".*" ".*" ".*"
  echo "User '$username' with password $(mask_secret "$password") created."
}

# -----------------------------------------------------------------------------
RABBITMQ_USERNAME=$(cat ${RABBITMQ_USERNAME_FILE})
RABBITMQ_PASSWORD=$(cat ${RABBITMQ_PASSWORD_FILE})

# NOTE: without the initial sleep, you will probably hit this issue:
# https://github.com/docker-library/rabbitmq/issues/114
# https://github.com/docker-library/rabbitmq/issues/318
echo "Waiting for RabbitMQ to be available ${RABBITMQ_USERNAME}:${RABBITMQ_PASSWORD}..."
echo "PID file ${RABBITMQ_PID_FILE}"
(
  sleep 10 &&
  rabbitmqctl wait "$RABBITMQ_PID_FILE"
  create_user "$RABBITMQ_USERNAME" "$RABBITMQ_PASSWORD"
) &

exec /usr/local/bin/docker-entrypoint.sh "$@"

#!/bin/bash

if [ -z $NAME ]; then
  echo Set "NAME" in docker-compose.env
fi

docker compose -p "redis_${NAME}" --env-file docker-compose.env down

docker stop "redis_${NAME}"
docker rm   "redis_${NAME}"

docker compose -p "redis_${NAME}" --env-file docker-compose.env up

#!/bin/bash

if [ -z $NAME ]; then
  echo Set "NAME" in docker-compose.env
fi

./stop.sh

docker compose -p "redis_${NAME}" --env-file docker-compose.env up

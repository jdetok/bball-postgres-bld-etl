#!/usr/bin/env bash

# build & run container
docker compose up --build -d || { echo "docker compose up failed"; exit 1; }

echo "docker compose up succesful"

# use health check to wait for database creation
until [ "$(docker inspect -f '{{.State.Health.Status}}' pgbball)" = "healthy" ]; do
    echo "waiting for container to return healthy status before continuing"
    sleep 1
done

# fetch & load to database
go run ./pgbld || { echo \
    "go etl process failed, compose down & exit"; \
    docker compose down --rmi all; exit 1; }
echo "go etl process successful"

# call procedures here
docker exec -i pgbball psql -U postgres -d bball < ./call.sql || \
    { echo "error calling procedures, compose down & exit"; \
        docker compose down --rmi all; exit 1; }

exit 0
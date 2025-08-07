#!/usr/bin/env bash

docker compose -f devcompose.yaml up --build -d || { echo "docker compose up failed"; exit 1; }

echo "docker compose up succesful"

# use health check to wait for database creation
until [ "$(docker inspect -f '{{.State.Health.Status}}' pgbballdev)" = "healthy" ]; do
    echo "waiting for container to return healthy status before continuing"
    sleep 1
done

# fetch & load to database
go run ./pgbld || { echo \
    "go etl process failed, compose down & exit"; \
    docker compose -f devcompose.yaml down --rmi all; exit 1; }
echo "go etl process successful"

# call procedures here
docker exec -i pgbballdev psql -U postgres -d bballdev < ./call.sql || \
    { echo "error calling procedures, compose down & exit"; \
        docker compose -f devcompose.yaml down --rmi all; exit 1; }

exit 0
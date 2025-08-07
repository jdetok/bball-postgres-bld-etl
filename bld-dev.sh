#!/usr/bin/env bash

# build & run container
docker compose -f devcompose.yaml up --build -d || echo "docker compose up failed" 

echo "docker compose up succesful"

# use health check to wait for database creation
until [ "$(docker inspect -f '{{.State.Health.Status}}' devpg)" = "healthy" ]; do
    echo "waiting for container to return healthy status before continuing"
    sleep 1
done

# fetch & load to database
go run ./pgbld || echo "go etl process failed" 
echo "go etl process successful"

# call procedures here
docker exec -i devpg psql -U postgres -d bball < ./call.sql

exit 0
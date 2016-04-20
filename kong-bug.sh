#!/bin/bash
echo "Killing all potentially conflicting containers"
docker stop postgres_kong kong_dead kong_alive
docker rm postgres_kong kong_alive kong_dead
echo "Containers killed"
docker run -d --name postgres_kong -e "POSTGRES_PASSWORD=postgres" --expose 5432 postgres
echo "Waiting for postgres to start"
sleep 5
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
docker run -d --name kong_dead -v `pwd`/kong.yml:/etc/kong/kong.yml -v `pwd`/start.sh:/start.sh --link postgres_kong:db --expose 7946 mashape/kong:0.8.0 bash start.sh
echo "Waiting for first kong to boot"
sleep 10
docker exec kong_dead cat /usr/local/kong/serf.log
docker logs kong_dead
echo "Postgres status after first node alive:"
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
echo "Killing node"
docker exec kong_dead pkill -9 nginx
docker exec kong_dead pkill -9 serf
docker exec kong_dead pkill -9 dnsmasq
echo "Waiting incase the node removes itself already"
sleep 5
echo "Is bad node still in postgres?"
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
echo "Starting a new node"
docker run -d --name kong_alive -v `pwd`/kong.yml:/etc/kong/kong.yml -v `pwd`/start.sh:/start.sh --link postgres_kong:db --expose 7946 mashape/kong:0.8.0 bash start.sh
echo "Waiting for new node to boot"
sleep 2
docker logs kong_dead
echo "Checking Postgres"
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
sleep 1
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
sleep 1
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
sleep 1
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
sleep 1
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
sleep 1
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
sleep 1
docker run --link postgres_kong:postgres erikswanson/docker-postgres-client psql -c 'SELECT * from nodes'
sleep 1

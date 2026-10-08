#!/usr/bin/env bash
set -e

docker rm -f -v klyauzin-01-web klyauzin-01-db 2>/dev/null || true

docker build --build-arg VERSION=2.0 -t klyauzin-01/probe:2.0 .

docker volume create klyauzin-01-data

docker run -d --name klyauzin-01-db \
  -e POSTGRES_PASSWORD=lab \
  -e POSTGRES_DB=lab \
  -p 8005:5432 \
  -v klyauzin-01-data:/var/lib/postgresql/data \
  postgres:16-alpine

docker run -d --name klyauzin-01-web \
  --add-host host.docker.internal:host-gateway \
  -p 8003:5001 \
  -e APP_PORT=5001 \
  -e DATABASE_URL=postgresql://postgres:lab@host.docker.internal:8005/lab \
  klyauzin-01/probe:2.0

SECONDS=0
until curl -sf -m 3 localhost:8003/notes > /dev/null || [ $SECONDS -ge 60 ]; do
  sleep 2
done

curl -s localhost:8003/notes

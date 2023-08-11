#!/bin/sh
set -euo pipefail

usage() {
  echo "Start a test docker container and run a test suite locally"
  echo "Usage: $0 <suite>"
  echo "  <suite> - test suite to run"
}

cleanup() {
  docker compose -f docker-compose.testing.yaml down -v
  echo "Done"
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

trap cleanup EXIT
docker compose -f docker-compose.testing.yaml up -d --build
sleep 5 # wait for the database to be ready
docker compose -f docker-compose.testing.yaml exec php /bin/bash -c "cd /var/www/html/tests && php ../vendor/phpunit/phpunit/phpunit --debug --stderr --verbose --testsuite $1"

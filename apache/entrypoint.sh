#!/usr/bin/env sh
/cron-runner.sh &
exec docker-php-entrypoint "$@"
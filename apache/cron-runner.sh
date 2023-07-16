#!/usr/bin/env sh

# YetiForce CRM requires a certain file to be ran every minute.
# We could do this in a separate container, but that would necessitate running the job over the network,
# which would risk request timeouts and other issues.
# Instead, we run it in the same container, but in a separate process.
# This is discouraged by Docker because it might be harder to monitor for users,
# but in this case, the YetiForce CRM has a mechanism to ensure that cron jobs are running properly.
# We can rely on that to monitor the cron job and tell the user if jobs are not running.
while true
do
  /var/www/html/cron/cron.sh
  sleep 60
done

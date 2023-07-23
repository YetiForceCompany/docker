#!/usr/bin/env bash
set -euxo pipefail

while true
do
	if test -f "/crm/config/Main.php"; then
		unique_key=$(grep application_unique_key /crm/config/Main.php | awk -F"'" '{print $2}')
		wget --timeout=900 -qO- http://nginx/cron.php?app_key="${unique_key}"
	fi

	sleep 60
done


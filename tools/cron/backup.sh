#!/bin/bash

DATE=$(date +%m%d%y)
TARGETS="infrastructure_buildbot_config infrastructure_discourse_shared infrastructure_discourse_logs infrastructure_fathom_secrets infrastructure_gerrit_data infrastructure_grafana_data infrastructure_hds_secrets infrastructure_minio_config infrastructure_pootle_data infrastructure_postgres_data infrastructure_prometheus_data infrastructure_redis_data infrastructure_s3_secrets infrastructure_smtp_keys infrastructure_trac_data infrastructure_traefik_acme infrastructure_userguide_data"
TOTAL=0
OUTPUT="/var/backups"

ZIPPASS=$(cat /root/.secret)

# Every day of week, update backup-latest.tar
for i in $TARGETS; do
	SIZE=$(du -s /var/lib/docker/volumes/$i | awk ' { print $1 } ')
	TOTAL=$(expr $TOTAL + $SIZE)
	tar -uvf $OUTPUT/backup-latest.tar /var/lib/docker/volumes/$i
done

# Every Sunday, 'archive' the backup-latest.tar and start again.
# Also delete archives over 30 days old
if [[ $(date +"%u") -eq 7 ]]; then
	echo "Compressing..."
	7za a -t7z -p$ZIPPASS -mx=1 $OUTPUT/backup-$DATE.tar.7z $OUTPUT/backup-latest.tar
	rm $OUTPUT/backup-latest.tar
	echo "Cleaning up over 30 days..."
	find $OUTPUT  -mtime +30 | xargs rm
fi
